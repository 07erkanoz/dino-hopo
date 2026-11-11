from pathlib import Path
import wave,math,random,struct
p=Path(__file__).resolve().parents[1]
(p/"audio/sfx").mkdir(parents=True,exist_ok=True)
# Original procedural cartoon effects, no external audio samples.
rate=44100
for kind,duration in [('swing',.18),('wood_hit',.16),('recoil_a',.40),('recoil_b',.34)]:
 rng=random.Random(81);filtered=0.;phase=0.;samples=[]
 for i in range(int(rate*duration)):
  t=i/rate;u=t/duration; noise=rng.uniform(-1,1)
  if kind=='swing':
   filtered+=(.08+.35*u)*(noise-filtered);value=filtered*math.sin(math.pi*u)**1.5
  elif kind=='wood_hit':
   value=(math.sin(math.tau*220*t)*math.exp(-37*t)+.4*math.sin(math.tau*790*t)*math.exp(-75*t)+.65*noise*math.exp(-95*t))*(1-math.exp(-1500*t))
  else:
   freq=(130+460*math.exp(-15*t)+27*math.sin(math.tau*12*t)*math.exp(-5*t)) if kind=='recoil_a' else (160+220*math.exp(-18*t)+45*math.sin(math.tau*8*t)*math.exp(-5*t))
   phase+=math.tau*freq/rate
   value=(math.sin(phase)+.23*math.sin(phase*2)+.09*math.sin(phase*3))*(1-math.exp(-100*t))*math.exp(-9*t)
  value*=min(1,(duration-t)/.015)
  samples.append(value)
 peak=max(abs(x) for x in samples) or 1
 with wave.open(str(p/'audio/sfx'/f'{kind}.wav'),'wb') as wav:
  wav.setnchannels(1);wav.setsampwidth(2);wav.setframerate(rate);wav.writeframes(b''.join(struct.pack('<h',int(v/peak*.7*32767)) for v in samples))
