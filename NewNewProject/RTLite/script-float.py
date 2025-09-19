import matplotlib.pyplot as plt 
import tensorflow as tf 
import numpy as np 
import random
# from ai_edge_litert.interpreter import Interpreter


# Load the MNIST Train and Test Dataset 
mnist = tf.keras.datasets.mnist 
(x_train, y_train), (x_test, y_test) = mnist.load_data()  
rows, cols = 28, 28  
# Display Random Samples 
fig = plt.figure(figsize=(9,9)) 
for i in range(8): 
    ind = random.randint(0, len(x_train)) 
    plt.subplot(3,3,i+1) 
    plt.imshow(x_train[ind], cmap="gray", interpolation=None) 
    plt.title(y_train[ind])
# just uncomment this if u wanna see dataset 
# plt.show()

##### Pre processing data ####

# Reshape the data into a 4D Array 
x_train = x_train.reshape(x_train.shape[0], rows, cols, 1) 
x_test = x_test.reshape(x_test.shape[0], rows, cols, 1)  

input_shape = (rows,cols,1)  
# Set type as float32 and normalize the values to [0,1] 
x_train = x_train.astype('float32') 
x_test = x_test.astype('float32') 
x_train = x_train / 255.0 
x_test = x_test / 255.0  
# Transform labels to one hot encoding 
y_train = tf.keras.utils.to_categorical(y_train, 10) 
y_test = tf.keras.utils.to_categorical(y_test, 10)

print("[PRIME OUTPUT] Pre Processing done")

###### Constructing Model Architecture #####

# Construct a Sequential  model 
model = tf.keras.Sequential()  
# Input Layer 
model.add(tf.keras.layers.Input(shape=input_shape)) 
# C1 Convolution Layer 
model.add(tf.keras.layers.Conv2D(filters=6, strides=(1,1), kernel_size=(5,5), activation='relu')) 
# S2 SubSampling Layer 
model.add(tf.keras.layers.AveragePooling2D(pool_size=(2,2), strides=(2,2))) 
# C3 Convolution Layer 
model.add(tf.keras.layers.Conv2D(filters=6, strides=(1,1), kernel_size=(5,5), activation='relu')) 
# S4 SubSampling Layer 
model.add(tf.keras.layers.AveragePooling2D(pool_size=(2,2), strides=(2,2))) 
# C5 Fully Connected Layer 
model.add(tf.keras.layers.Dense(units=120, activation='relu')) 
# Flatten Layer 
model.add(tf.keras.layers.Flatten()) 
# FC6 Fully Connected Layer 
model.add(tf.keras.layers.Dense(units=84, activation='relu')) 
# Output Layer 
model.add(tf.keras.layers.Dense(units=10, activation='softmax'))  
print("[PRIME OUTPUT] Model constructed")
# Display a Summary of the  model  
model.summary()

############ Configure Model ##########
# Compile the Model 
model.compile(loss = tf.keras.metrics.categorical_crossentropy, optimizer = "adam", metrics = ['accuracy'])

print("[PRIME OUTPUT] Model Compiled")

######### Training Model ############

# Train and Validate the Model 
epochs = 10 
history = model.fit(x_train, y_train, epochs=epochs, batch_size=128, validation_data = (x_test, y_test), verbose=1)  
# Display the Training Progress 
def summary_history(history): 
    plt.figure(figsize = (10,6)) 
    plt.plot(history.history['accuracy'], color = 'blue', label = 'train') 
    plt.plot(history.history['val_accuracy'], color = 'red', label = 'val') 
    plt.legend() 
    plt.title('Accuracy') 
    plt.show()  
    
summary_history(history)


# Evaluate Accuracy of the Model 
loss ,acc= model.evaluate(x_test, y_test) 
print('Accuracy : ', acc)

# Save Model 
model.save('lenet.keras')
print("[PRIME OUTPUT] Saved model")


# Load Model
model = tf.keras.models.load_model('lenet.keras')

# Convert the model from Tensorflow to LiteRT model
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the LiteRT model
open("lenet.tflite", "wb").write(tflite_model)

# Analyse the LiteRT Model

tf.lite.experimental.Analyzer.analyze(model_path="lenet.tflite")



# Load the LiteRT model in TFLite Interpreter
interpreter = tf.lite.Interpreter(model_path="lenet.tflite")
# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()
# Adjust the model interpreter to take 10,000 inputs at once instead of just 1
interpreter.resize_tensor_input(input_details[0]["index"], (x_test.shape[0], rows, cols, 1))
interpreter.resize_tensor_input(output_details[0]["index"], (y_test.shape[0], 10))
interpreter.allocate_tensors()
# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()


# Evaluate RTLite Model
# Set the test input and run
interpreter.set_tensor(input_details[0]["index"], x_test)
interpreter.invoke()
# Get the result and check its accuracy
output_data = interpreter.get_tensor(output_details[0]["index"])
a = [np.argmax(y, axis=None, out=None) for y in output_data]
b = [np.argmax(y, axis=None, out=None) for y in y_test]
accuracy = (np.array(a) == np.array(b)).mean()
print("TFLite Accuracy:", accuracy)