# Image Processor in Verilog (Mirroring, Grayscale, and More)

## Project Description

This project implements an image processing module in Verilog, designed to handle fundamental image transformations. The main features include:

1. **Image Mirroring**: Horizontally mirrors an image by swapping pixels across the vertical axis.
2. **Grayscale Conversion**: Converts a colored image into grayscale using the minimum and maximum pixel values.
3. **Modular Design**: The code uses a Finite State Machine (FSM) to control different stages of image processing.
   
The project can be integrated into FPGA-based image processing pipelines and extended for other transformations or optimizations.

## Features

- **Image Mirroring**: Flips the image horizontally by reordering pixel positions across the center vertical axis.
- **Grayscale Conversion**: Converts RGB images to grayscale using a simple min-max method for pixel value calculation.
- **FSM Design**: Manages each stage of image processing with a finite state machine for clear and modular execution.
- **FPGA Compatibility**: Designed to be implemented in FPGA systems that process image data in real-time.

## Project Structure

- **image_processor.v**: Verilog module that implements the image processing functionalities.
- **testbench.v**: A testbench for simulating the image processor and verifying its correctness.
  
## Algorithmic Details

### Image Mirroring
- Each pixel from a row is swapped with its corresponding pixel on the opposite side of the image.
- The module processes pixels row by row, iterating through each column and performing the swap.
  
### Grayscale Conversion
- Converts an image to grayscale by calculating the average intensity using the minimum and maximum RGB values of each pixel.
  
## Usage

### Prerequisites
- Verilog simulation tool (e.g., ModelSim, Icarus Verilog)
- Basic understanding of Verilog and image processing
- FPGA platform (optional for hardware testing)

### Simulation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/verilog-image-processor.git
