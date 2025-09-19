import matplotlib.pyplot as plt
import tensorflow as tf
import numpy as np
import random
import tensorflow_model_optimization as tfmot

# Load MNIST dataset
mnist = tf.keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()
rows, cols = 28, 28
input_shape = (rows,cols,1)

# Plot samples
fig = plt.figure(figsize=(9, 9))
for i in range(8):
    ind = random.randint(0, len(x_train) - 1)
    plt.subplot(3, 3, i + 1)
    plt.imshow(x_train[ind], cmap="gray", interpolation=None)
    plt.title(y_train[ind])
# plt.show()  # Optional: View dataset

# Preprocess data
x_train = x_train.reshape(-1, rows, cols, 1).astype("float32") / 255.0
x_test = x_test.reshape(-1, rows, cols, 1).astype("float32") / 255.0
y_train = tf.keras.utils.to_categorical(y_train, 10)
y_test = tf.keras.utils.to_categorical(y_test, 10)

print("[PRIME OUTPUT] Pre Processing done")

# Define original model
def build_model():
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(input_shape)),
        tf.keras.layers.Conv2D(6, kernel_size=5, activation='relu'),
        tf.keras.layers.AveragePooling2D(),
        tf.keras.layers.Conv2D(6, kernel_size=5, activation='relu'),
        tf.keras.layers.AveragePooling2D(),
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(120, activation='relu'),
        tf.keras.layers.Dense(84, activation='relu'),
        tf.keras.layers.Dense(10, activation='softmax')
    ])
    return model

# Apply quantization-aware training
quantize_model = tfmot.quantization.keras.quantize_model
qat_model = quantize_model(build_model())

qat_model.compile(optimizer='adam',
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])

print("[PRIME OUTPUT] Model constructed and compiled (QAT enabled)")
qat_model.summary()

# Train the model
epochs = 10
history = qat_model.fit(x_train, y_train,
                        batch_size=128,
                        epochs=epochs,
                        validation_data=(x_test, y_test))

# Plot accuracy
def summary_history(history):
    plt.figure(figsize=(10, 6))
    plt.plot(history.history['accuracy'], label='Train Accuracy', color='blue')
    plt.plot(history.history['val_accuracy'], label='Validation Accuracy', color='red')
    plt.legend()
    plt.title("Model Accuracy During Training")
    plt.show()

summary_history(history)

# Evaluate accuracy
loss, acc = qat_model.evaluate(x_test, y_test)
print('Final Accuracy:', acc)

# Save QAT model (optional)
qat_model.save('lenet_qat.keras')

# Convert to fully INT8 TFLite
def representative_data_gen():
    for i in range(100):
        yield [x_train[i:i+1]]

converter = tf.lite.TFLiteConverter.from_keras_model(qat_model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.representative_dataset = representative_data_gen
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8
tflite_model = converter.convert()

# Save TFLite model
with open("lenet_int8_qat.tflite", "wb") as f:
    f.write(tflite_model)

# Analyze TFLite model
tf.lite.experimental.Analyzer.analyze(model_path="lenet_int8_qat.tflite")

# Load TFLite model
interpreter = tf.lite.Interpreter(model_path="lenet_int8_qat.tflite")
interpreter.allocate_tensors()

# Get tensor details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()
print("Input details:", input_details)
print("Output details:", output_details)

# Quantize test input to int8 range
input_scale, input_zero_point = input_details[0]["quantization"]
x_test_int8 = x_test / input_scale + input_zero_point
x_test_int8 = np.clip(np.round(x_test_int8), -128, 127).astype(np.int8)

# Resize for batch inference
interpreter.resize_tensor_input(input_details[0]["index"], (x_test_int8.shape[0], 28, 28, 1))
interpreter.allocate_tensors()
interpreter.set_tensor(input_details[0]["index"], x_test_int8)
interpreter.invoke()

# Get prediction
output_data = interpreter.get_tensor(output_details[0]["index"])
y_pred = np.argmax(output_data, axis=1)
y_true = np.argmax(y_test, axis=1)
accuracy = np.mean(y_pred == y_true)
print("TFLite INT8 Accuracy:", accuracy)
