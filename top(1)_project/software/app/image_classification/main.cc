#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <math.h>
#include "system.h"
#include <time.h>
#include <unistd.h>

// Import TensorFlow Lite libraries
#include "tensorflow/lite/core/c/common.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_log.h"
#include "tensorflow/lite/micro/micro_time.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/micro_profiler.h"
#include "tensorflow/lite/micro/recording_micro_interpreter.h"
#include "tensorflow/lite/micro/system_setup.h"
#include "tensorflow/lite/schema/schema_generated.h"

// Model data
#include "model/model_data_int8.h"
#include "model/model_settings.h"

// Sample images
#include "image/figure-0.h"
#include "image/figure-1.h"
#include "image/figure-2.h"
#include "image/figure-3.h"
#include "image/figure-4.h"
#include "image/figure-5.h"
#include "image/figure-6.h"
#include "image/figure-7.h"
#include "image/figure-8.h"
#include "image/figure-9.h"

#define IMAGE_WIDTH 28
#define IMAGE_HEIGHT 28
#define NUM_CHANNELS 1
#define IMAGE_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT * NUM_CHANNELS)

// ANSI Escape code
#define CRESET "\033[m"

int count;
int8_t test_image[IMAGE_HEIGHT][IMAGE_WIDTH][NUM_CHANNELS];
// Quantization parameters from your model
constexpr float kInputScale = 0.003921568859368563f;
constexpr int kInputZeroPoint = -128;
constexpr float kOutputScale = 0.00390625f;
constexpr int kOutputZeroPoint = -128;

namespace
{
    const tflite::Model *model = nullptr;

    using OpResolver = tflite::MicroMutableOpResolver<10>; // At least 10 to be safe

    TfLiteStatus RegisterOps(OpResolver &op_resolver)
    {
        TF_LITE_ENSURE_STATUS(op_resolver.AddConv2D());
        TF_LITE_ENSURE_STATUS(op_resolver.AddAveragePool2D());
        TF_LITE_ENSURE_STATUS(op_resolver.AddReshape());
        TF_LITE_ENSURE_STATUS(op_resolver.AddFullyConnected());
        TF_LITE_ENSURE_STATUS(op_resolver.AddSoftmax());
        TF_LITE_ENSURE_STATUS(op_resolver.AddQuantize());   // 🔥 Required for INT8
        TF_LITE_ENSURE_STATUS(op_resolver.AddDequantize()); // 🔥 Required for INT8
        TF_LITE_ENSURE_STATUS(op_resolver.AddRelu());       // Optional but common
        TF_LITE_ENSURE_STATUS(op_resolver.AddMul());        // Optional but sometimes present
        return kTfLiteOk;
    }

} // namespace

TfLiteStatus LoadModelandInference()
{
    printf("[INFO]Setting up TinyML...\n\r");

    tflite::MicroProfiler profiler;
    OpResolver op_resolver;
    TF_LITE_ENSURE_STATUS(RegisterOps(op_resolver));

    model = tflite::GetModel(lenet_int8_qat_tflite);
    TFLITE_CHECK_EQ(model->version(), TFLITE_SCHEMA_VERSION);

    /*
     * Arena size is a round number, which is determined
     * using the RecordingMicroInterpreter.
     */
    constexpr int kTensorArenaSize = 20000;
    uint8_t tensor_arena[kTensorArenaSize];
    constexpr int kNumResourceVariables = 24;

    tflite::RecordingMicroAllocator *allocator(
        tflite::RecordingMicroAllocator::Create(tensor_arena, kTensorArenaSize));

    tflite::RecordingMicroInterpreter Recordinginterpreter(
        model,
        op_resolver,
        allocator,
        tflite::MicroResourceVariables::Create(allocator, kNumResourceVariables),
        &profiler);

    TF_LITE_ENSURE_STATUS(Recordinginterpreter.AllocateTensors());
    TFLITE_CHECK_EQ(Recordinginterpreter.inputs_size(), 1);

    // Print loaded model input and output shape
    printf("Total output layers: %d\n\r", Recordinginterpreter.outputs_size());
    // printf(
    //     "Input shape: %d dimensions. Dimension: %d %d %d %d. Type: %d\n\r",
    //     Recordinginterpreter.input(0)->dims->size,
    //     Recordinginterpreter.input(0)->dims->data[0],
    //     Recordinginterpreter.input(0)->dims->data[1],
    //     Recordinginterpreter.input(0)->dims->data[2],
    //     Recordinginterpreter.input(0)->dims->data[3],
    //     Recordinginterpreter.input(0)->type);

    // for (int i = 0; i < (int)(Recordinginterpreter.outputs_size()); ++i)
    // {
    //     printf(
    //         "Output shape %d: %d dimensions. Dimension: %d %d. Type: %d\n\r",
    //         i,
    //         Recordinginterpreter.output(i)->dims->size,
    //         Recordinginterpreter.output(i)->dims->data[0],
    //         Recordinginterpreter.output(i)->dims->data[1],
    //         Recordinginterpreter.output(i)->type);
    // }

    printf("[INFO]Setting up TinyML...Done\n\n\r");
    printf("[INFO]Uploading image...\n\r");

    // Visualize sample image in terminal
    int HashTag = 35; // ASCII code for '#'
    for (int i = 0; i < IMAGE_HEIGHT; i = i + 2)
    {
        for (int j = 0; j < IMAGE_WIDTH; j = j + 2)
        {
            printf(
                "\033[38;2;%d;%d;%dm%c" CRESET,
                test_image[i][j][0] + 128,
                test_image[i][j][0] + 128,
                test_image[i][j][0] + 128,
                HashTag);
        }
        printf("\n");
    }
    printf("\n");

    // Input sample image to tflite model input.
    int len = 0;
    for (int i = 0; i < IMAGE_HEIGHT; i++)
    {
        for (int j = 0; j < IMAGE_WIDTH; j++)
        {
            for (int k = 0; k < NUM_CHANNELS; k++)
            {
                Recordinginterpreter.input(0)->data.int8[len] = test_image[i][j][k];
                len++;
            }
        }
    }

    printf("[INFO]Uploading image...Done\n\n\r");

    printf("[INFO]Classifying image...\n\r");
    clock_t startTime = clock();
    TF_LITE_ENSURE_STATUS(Recordinginterpreter.Invoke());
    clock_t endTime = clock();
    printf("[INFO]Classifying image...Done\n\n\r");

    // Retrieve inference output
    int answer = 0;
    printf("Retrieve the inference output:\n");
    for (int i = 0; i < kCategoryCount; ++i)
    {
        int8_t out_val = Recordinginterpreter.output(0)->data.int8[i];
        // float score = (out_val - kOutputZeroPoint) * kOutputScale;
        printf("%s score: %d\n\r", kCategoryLabels[i], out_val);
        if (out_val > ((Recordinginterpreter.output(0)->data.int8[answer] - kOutputZeroPoint) * kOutputScale))
            answer = i;
    }

    printf("\nInference made: %s\n\r", kCategoryLabels[answer]);

    int time_spent = int(endTime - startTime) / 1;
    printf("Inference time: %d milli seconds\n\n\r", time_spent);

    printf("[INFO]Profiling TinyML model...\n\r");
    // profiler.LogTicksPerTagCsv();
    printf("Ticks per seconds: %d\n\n", ALT_CPU_TICKS_PER_SEC);

    printf("Tensor Arena Allocation:\n");
    // Recordinginterpreter.GetMicroAllocator().PrintAllocations();
    printf("[INFO]Profiling TinyML model...Done\n\n\r");

    return kTfLiteOk;
}

int SelectImage(int8_t (*image)[IMAGE_WIDTH][NUM_CHANNELS])
{
    for (int i = 0; i < IMAGE_HEIGHT; i++)
    {
        for (int j = 0; j < IMAGE_WIDTH; j++)
        {
            for (int k = 0; k < NUM_CHANNELS; k++)
            {
                test_image[i][j][k] = image[i][j][k];
            }
        }
    }

    TF_LITE_ENSURE_STATUS(LoadModelandInference());

    return 0;
}

int main()
{
    printf("\tHello from Nios V Processor TinyML Demonstration on MNIST\n\r");
    /*************************TFLITE-MICRO TINYML******************/

    SelectImage(test_image0);
    SelectImage(test_image1);
    SelectImage(test_image2);
    SelectImage(test_image3);
    SelectImage(test_image4);
    SelectImage(test_image5);
    SelectImage(test_image6);
    SelectImage(test_image7);
    SelectImage(test_image8);
    SelectImage(test_image9);

    return 0;
}
