"""Original two-note UI chimes; no third-party recordings or speech assets."""
import math
import struct
import wave

def build(directory):
    directory.mkdir(parents=True, exist_ok=True)
    rate = 22050
    for name, duration, notes in (('ready', .32, (740, 988)), ('active', .42, (523, 784))):
        samples=[]
        for i in range(round(rate*duration)):
            t=i/rate
            half=duration/2
            phase=t if t<half else t-half
            freq=notes[0 if t<half else 1]
            envelope=min(1,phase/.008)*math.exp(-phase*22)
            value=.16*envelope*(math.sin(2*math.pi*freq*phase)+.2*math.sin(4*math.pi*freq*phase))
            samples.append(round(32767*value))
        with wave.open(str(directory/(name+'.wav')), 'wb') as out:
            out.setnchannels(1);out.setsampwidth(2);out.setframerate(rate)
            out.writeframes(struct.pack('<'+'h'*len(samples), *samples))
