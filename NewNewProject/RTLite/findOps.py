import tensorflow as tf

interpreter = tf.lite.Interpreter(model_path="RTLite/lenet_int8_qat.tflite")
interpreter.allocate_tensors()

for d in interpreter.get_tensor_details():
    print(d['name'])
