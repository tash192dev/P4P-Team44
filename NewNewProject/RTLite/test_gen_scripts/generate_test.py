import numpy as np

# Constants
IMAGE_WIDTH = 28
IMAGE_HEIGHT = 28
NUM_CHANNELS = 1

# Generate identifiable values
data = np.arange(IMAGE_HEIGHT * IMAGE_WIDTH * NUM_CHANNELS, dtype=np.int8)
data = data.reshape((IMAGE_HEIGHT, IMAGE_WIDTH, NUM_CHANNELS))

# Begin C header string
header = '''#include <stdint.h>

#define IMAGE_WIDTH {w}
#define IMAGE_HEIGHT {h}
#define NUM_CHANNELS {c}
#define IMAGE_SIZE (IMAGE_WIDTH * IMAGE_HEIGHT * NUM_CHANNELS)

int8_t test_image_identifiable[IMAGE_HEIGHT][IMAGE_WIDTH][NUM_CHANNELS] = {{
'''.format(w=IMAGE_WIDTH, h=IMAGE_HEIGHT, c=NUM_CHANNELS)

# Format data correctly
lines = []
for i in range(IMAGE_HEIGHT):
    lines.append(" {")
    row_items = []
    for j in range(IMAGE_WIDTH):
        pixel = ', '.join([f'{data[i][j][k]}' for k in range(NUM_CHANNELS)])
        row_items.append(f"  {{{pixel}}}")
    lines.append(',\n'.join(row_items))
    lines.append(" },")
lines[-1] = lines[-1][:-1]  # Remove trailing comma from the last block

footer = '};\n'

# Write to file
with open("identifiable_image.h", "w") as f:
    f.write(header)
    for line in lines:
        f.write(line + '\n')
    f.write(footer)

print("✅ Valid C header file 'identifiable_image.h' has been generated.")
