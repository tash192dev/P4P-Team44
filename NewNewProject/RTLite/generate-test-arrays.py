# Convert MNIST samples into a C array

import matplotlib.pyplot as plt
import tensorflow as tf
import numpy as np
import random
import sys


#Quantization data from acutal model
interpreter = tf.lite.Interpreter(model_path="lenet_int8_qat.tflite")
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
input_scale, input_zero_point = input_details[0]['quantization']


# Load the MNIST Train and Test Dataset
mnist = tf.keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()

rows, cols = 28, 28

# Reshape the data into a 4D Array
x_test = x_test.reshape(x_test.shape[0], rows, cols, 1)
input_shape = (rows, cols, 1)

# Set type as float32 and normalize the values to [0,1]
x_test = x_test.astype('float32')
x_test = x_test / 255.0

# Transform labels to one hot encoding
y_test = tf.keras.utils.to_categorical(y_test, 10)

img = x_test / input_scale + input_zero_point
img = np.clip(np.round(img), -128, 127).astype(np.int8)
img_label = np.argmax(y_test, axis=1)

# Repeat for a few rounds to get all numbers (0-9)
fig = plt.figure(figsize=(9, 9))

for i in range(9):
    ind = random.randint(0, len(img))
    np.set_printoptions(threshold=sys.maxsize)
    string1 = np.array2string(img[ind], separator=', ')
    c_array = string1.replace('[', '{').replace(']', '}').replace('.', '')
    c_array_label = img_label[ind]

    plt.subplot(3, 3, i + 1)
    plt.imshow(img[ind], cmap="gray", interpolation=None)
    plt.title(c_array_label)

    base_path = "figure-"
    label_name = str(c_array_label)
    file_type = ".h"
    file_name = base_path + label_name + file_type

    with open(file_name, "w") as f:
        f.write("#include <stdint.h>\n\n")
        f.write("#define IMAGE_WIDTH 28\n")
        f.write("#define IMAGE_HEIGHT 28\n")
        f.write("#define NUM_CHANNELS 1\n")
        f.write("#define IMAGE_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT * NUM_CHANNELS)\n\n")
        f.write("int8_t test_image{}[IMAGE_HEIGHT][IMAGE_WIDTH][NUM_CHANNELS] = ".format(c_array_label))
        f.write(c_array)
        f.write(";")

