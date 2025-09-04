class AudioStreamProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    
    // queues for left and right channels
    this.leftBufferQueue = [];
    this.rightBufferQueue = [];
    
    // currently being processed
    this.currentLeftBuffer = null;
    this.currentRightBuffer = null;
    
    this.leftBufferIndex = 0;
    this.rightBufferIndex = 0;

    this.samplesProcessed = 0;
    this.silentSamples = 0;
    this.isPlaying = false;
    
    // route messages sent from main thread
    this.port.onmessage = (event) => {
      if (event.data.type === 'audioData') {
        // queue audio samples
        this.leftBufferQueue.push(event.data.leftBuffer);
        this.rightBufferQueue.push(event.data.rightBuffer);
      } else if (event.data.type === 'start') {
        this.isPlaying = true;
        this.port.postMessage({ type: 'dataRequest' });
      } else if (event.data.type === 'stop') {
        this.isPlaying = false;
        // reset buffers
        this.leftBufferQueue = [];
        this.rightBufferQueue = [];
        this.currentLeftBuffer = null;
        this.currentRightBuffer = null;
        this.leftBufferIndex = 0;
        this.rightBufferIndex = 0;
      } else if (event.data.type === 'pause') {
        this.isPlaying = false;
        // keep buffers for resume
      } else if (event.data.type === 'resume') {
        this.isPlaying = true;
        if (this.leftBufferQueue.length <= 2) {
          this.port.postMessage({ type: 'dataRequest' });
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
        
        // count silent samples (when both channels are silent)
        if (leftSample === 0 && rightSample === 0) {
          this.silentSamples++;
        } else {
          this.silentSamples = 0;
        }
      } else {
        // output silence because !isPlaying
        leftChannel[i] = 0;
        rightChannel[i] = 0;
      }
      this.samplesProcessed++;
    }

    // request data when playing and buffer is getting low OR when we are producing silence
    if (this.isPlaying && (this.leftBufferQueue.length <= 2 || this.silentSamples > 1024)) {
      this.port.postMessage({ type: 'dataRequest' });
      // reset count
      if (this.silentSamples > 1024) {
        this.silentSamples = 0;
      }
    }

    // log status every 8192 samples
    if (this.samplesProcessed % 8192 === 0) {
      this.port.postMessage({
        type: 'bufferStatus',
        queueLength: this.leftBufferQueue.length,
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

registerProcessor('audio-stream-processor', AudioStreamProcessor);