import matplotlib.pyplot as plt 
import tensorflow as tf 
import numpy as np 
import random



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
plt.show()

##### Pre processing data ####

# Reshape the data into a 4D Array 
x_train = x_train.reshape(x_train.shape[0], rows, cols, 1) 
x_test = x_test.reshape(x_test.shape[0], rows, cols, 1)  

input_shape = (rows,cols,1)  
# Set type as int_8 and normalize the values to [0,1] 
x_train = x_train.astype('int8') 
x_test = x_test.astype('int8') 
# x_train = x_train / 255.0 
# x_test = x_test / 255.0  
# Transform labels to one hot encoding 
y_train = tf.keras.utils.to_categorical(y_train, 10) 
y_test = tf.keras.utils.to_categorical(y_test, 10)

print("[PRIME OUTPUT] Pre Processing done")

# Load the LiteRT model in TFLite Interpreter
interpreter = tf.lite.Interpreter(model_path="lenet_int8_qat.tflite")
# Get input and output tensors.
input_details = interpreter.get_input_details()
print("################## Input details ##################")
print(input_details)

output_details = interpreter.get_output_details()
print("################## output details ##################")
print(output_details)
# Adjust the model interpreter to take 10,000 inputs at once instead of just 1
interpreter.resize_tensor_input(input_details[0]["index"], (x_test.shape[0], rows, cols, 1))
interpreter.resize_tensor_input(output_details[0]["index"], (y_test.shape[0], 10))

interpreter.allocate_tensors()
# Get input and output tensors.
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print("scale:", input_details[0]['quantization'][0])
print("zero_point:", input_details[0]['quantization'][1])
# Evaluate RTLite Model
# Set the test input and run
# Proper quantization
input_scale, input_zero_point = input_details[0]['quantization']
x_test_norm = x_test.astype('float32') / 255.0
print("TYPE OF X_TEST_NORM" + str(type(x_test_norm)))
x_test_quant = (x_test_norm / input_scale + input_zero_point).astype('int8')
# print(x_test_quant)
# Set input and run
interpreter.set_tensor(input_details[0]["index"], x_test_quant)
interpreter.invoke()
# Get the result and check its accuracy
output_data = interpreter.get_tensor(output_details[0]["index"])
a = [np.argmax(y, axis=None, out=None) for y in output_data]
b = [np.argmax(y, axis=None, out=None) for y in y_test]
accuracy = (np.array(a) == np.array(b)).mean()
print("TFLite Accuracy:", accuracy)