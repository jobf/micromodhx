var code = '

class AudioStreamProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    
    // Separate buffer queues for left and right channels
    this.leftBufferQueue = [];
    this.rightBufferQueue = [];
    
    // Current buffers being processed
    this.currentLeftBuffer = null;
    this.currentRightBuffer = null;
    
    // Buffer indices for each channel
    this.leftBufferIndex = 0;
    this.rightBufferIndex = 0;
    
    this.samplesProcessed = 0;
    this.silentSamples = 0;
    this.isPlaying = false;
    
    this.port.onmessage = (event) => {
      if (event.data.type === \'audioData\') {
        // Now handle the separate left and right buffers directly
        this.leftBufferQueue.push(event.data.leftBuffer);
        this.rightBufferQueue.push(event.data.rightBuffer);
      } else if (event.data.type === \'start\') {
        this.isPlaying = true;
        this.port.postMessage({ type: \'needMoreData\' });
      } else if (event.data.type === \'stop\') {
        this.isPlaying = false;
        // Clear all pending buffers
        this.leftBufferQueue = [];
        this.rightBufferQueue = [];
        this.currentLeftBuffer = null;
        this.currentRightBuffer = null;
        this.leftBufferIndex = 0;
        this.rightBufferIndex = 0;
      } else if (event.data.type === \'pause\') {
        this.isPlaying = false;
        // Keep buffers for resume
      } else if (event.data.type === \'resume\') {
        this.isPlaying = true;
        if (this.leftBufferQueue.length <= 2) {
          this.port.postMessage({ type: \'needMoreData\' });
        }
      }
    };
  }

  process(inputs, outputs, parameters) {
    const output = outputs[0];
    const leftChannel = output[0];
    const rightChannel = output[1];

    for (let i = 0; i < leftChannel.length; i++) {
      if (this.isPlaying) {
        const leftSample = this.getNextLeftSample();
        const rightSample = this.getNextRightSample();
        
        leftChannel[i] = leftSample;
        rightChannel[i] = rightSample;
        
        // Count silent samples (when both channels are silent)
        if (leftSample === 0 && rightSample === 0) {
          this.silentSamples++;
        } else {
          this.silentSamples = 0;
        }
      } else {
        // Not playing - output silence
        leftChannel[i] = 0;
        rightChannel[i] = 0;
      }
      this.samplesProcessed++;
    }

    // Request more data when playing and buffer is getting low OR when we are producing silence
    if (this.isPlaying && (this.leftBufferQueue.length <= 2 || this.silentSamples > 1024)) {
      this.port.postMessage({ type: \'needMoreData\' });
      if (this.silentSamples > 1024) {
        this.silentSamples = 0; // Reset to avoid spam
      }
    }

    // Log status periodically
    if (this.samplesProcessed % 8192 === 0) {
      this.port.postMessage({
        type: \'bufferStatus\',
        queueLength: this.leftBufferQueue.length, // Use left queue length for compatibility
        samplesProcessed: this.samplesProcessed,
        silentSamples: this.silentSamples,
        isPlaying: this.isPlaying
      });
    }

    return true;
  }

  getNextLeftSample() {
    if (!this.currentLeftBuffer || this.leftBufferIndex >= this.currentLeftBuffer.length) {
      if (this.leftBufferQueue.length > 0) {
        this.currentLeftBuffer = this.leftBufferQueue.shift();
        this.leftBufferIndex = 0;
      } else {
        return 0;
      }
    }

    if (this.currentLeftBuffer && this.leftBufferIndex < this.currentLeftBuffer.length) {
      return this.currentLeftBuffer[this.leftBufferIndex++];
    }
    return 0;
  }

  getNextRightSample() {
    if (!this.currentRightBuffer || this.rightBufferIndex >= this.currentRightBuffer.length) {
      if (this.rightBufferQueue.length > 0) {
        this.currentRightBuffer = this.rightBufferQueue.shift();
        this.rightBufferIndex = 0;
      } else {
        return 0;
      }
    }

    if (this.currentRightBuffer && this.rightBufferIndex < this.currentRightBuffer.length) {
      return this.currentRightBuffer[this.rightBufferIndex++];
    }
    return 0;
  }
}

registerProcessor(\'audio-stream-processor\', AudioStreamProcessor);

';