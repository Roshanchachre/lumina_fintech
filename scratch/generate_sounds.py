import os
import math
import wave
import struct

output_dir = "/Users/roshanchachre/.gemini/antigravity/scratch/lumina_fintech/assets/sounds"
os.makedirs(output_dir, exist_ok=True)

SAMPLE_RATE = 44100

def write_wav(filename, samples):
    path = os.path.join(output_dir, filename)
    with wave.open(path, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(SAMPLE_RATE)
        # Normalize and clamp
        max_val = max(abs(s) for s in samples) if samples else 1.0
        if max_val == 0: max_val = 1.0
        norm_factor = 32000.0 / max_val
        data = bytearray()
        for s in samples:
            val = int(s * norm_factor)
            val = max(-32767, min(32767, val))
            data.extend(struct.pack('<h', val))
        wav_file.writeframes(data)
    print(f"Generated {filename}: {len(samples)} samples ({len(samples)/SAMPLE_RATE:.2f}s)")

# 1. transfer_success.wav: Golden dual-bell chord (880Hz -> 1318.5Hz + harmonics)
def gen_transfer_success():
    duration = 0.8
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Envelope: fast attack, exponential decay
        env1 = math.exp(-t * 6.0)
        # Note 1: 880Hz (A5)
        s1 = math.sin(2 * math.pi * 880 * t) * env1
        s1 += 0.3 * math.sin(2 * math.pi * 1760 * t) * env1
        
        # Note 2 starts at t = 0.12s: 1318.5Hz (E6)
        s2 = 0.0
        if t >= 0.12:
            t2 = t - 0.12
            env2 = math.exp(-t2 * 5.0)
            s2 = math.sin(2 * math.pi * 1318.5 * t2) * env2
            s2 += 0.35 * math.sin(2 * math.pi * 2637 * t2) * env2
            s2 += 0.15 * math.sin(2 * math.pi * 3955 * t2) * env2
        samples.append(s1 * 0.7 + s2 * 1.0)
    write_wav("transfer_success.wav", samples)

# 2. wire_send.wav: Ascending frequency warp (slider snap)
def gen_wire_send():
    duration = 0.35
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Frequency glide from 380Hz to 950Hz
        freq = 380 + (950 - 380) * (t / duration) ** 1.5
        phase = 2 * math.pi * freq * t
        env = math.sin(math.pi * (t / duration)) ** 0.8
        s = math.sin(phase) * env
        # add sparkle harmonic
        s += 0.25 * math.sin(phase * 2.0) * env
        samples.append(s)
    write_wav("wire_send.wav", samples)

# 3. money_received.wav: Dual wealth resonance (528Hz Solfeggio & 1056Hz)
def gen_money_received():
    duration = 0.7
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env1 = math.exp(-t * 7.0)
        s1 = math.sin(2 * math.pi * 528 * t) * env1
        s1 += 0.4 * math.sin(2 * math.pi * 1056 * t) * env1
        
        s2 = 0.0
        if t >= 0.10:
            t2 = t - 0.10
            env2 = math.exp(-t2 * 6.0)
            s2 = math.sin(2 * math.pi * 1584 * t2) * env2
            s2 += 0.3 * math.sin(2 * math.pi * 2112 * t2) * env2
        samples.append(s1 * 0.6 + s2 * 1.0)
    write_wav("money_received.wav", samples)

# 4. biometric_unlock.wav: Futuristic crisp confirmation chirp
def gen_biometric_unlock():
    duration = 0.22
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env1 = math.exp(-t * 18.0) if t < 0.08 else 0.0
        s1 = math.sin(2 * math.pi * 1174.6 * t) * env1
        
        s2 = 0.0
        if t >= 0.07:
            t2 = t - 0.07
            env2 = math.exp(-t2 * 15.0)
            s2 = math.sin(2 * math.pi * 1760.0 * t2) * env2
        samples.append(s1 * 0.7 + s2 * 1.0)
    write_wav("biometric_unlock.wav", samples)

# 5. error_alert.wav: Muted low double-thud
def gen_error_alert():
    duration = 0.35
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env1 = math.exp(-t * 22.0) if t < 0.12 else 0.0
        s1 = math.sin(2 * math.pi * 180 * t) * env1
        
        s2 = 0.0
        if t >= 0.11:
            t2 = t - 0.11
            env2 = math.exp(-t2 * 20.0)
            s2 = math.sin(2 * math.pi * 135 * t2) * env2
        samples.append(s1 * 0.8 + s2 * 1.0)
    write_wav("error_alert.wav", samples)

# 6. card_click.wav: High-end tactile click
def gen_card_click():
    duration = 0.06
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 80.0)
        s = math.sin(2 * math.pi * 2400 * t) * env
        s += 0.3 * math.sin(2 * math.pi * 4800 * t) * env
        samples.append(s)
    write_wav("card_click.wav", samples)

# 7. vault_lock.wav: Heavy cinematic hydraulic latch
def gen_vault_lock():
    duration = 0.45
    num_samples = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Low frequency rumble + click
        env_rumble = math.exp(-t * 8.0)
        s_rumble = math.sin(2 * math.pi * 85 * (1 - t * 0.5) * t) * env_rumble
        
        # Click transient at start
        env_click = math.exp(-t * 90.0)
        s_click = (math.sin(2 * math.pi * 1200 * t) + math.sin(2 * math.pi * 2400 * t)) * env_click * 0.4
        
        samples.append(s_rumble * 0.9 + s_click * 0.5)
    write_wav("vault_lock.wav", samples)

if __name__ == '__main__':
    gen_transfer_success()
    gen_wire_send()
    gen_money_received()
    gen_biometric_unlock()
    gen_error_alert()
    gen_card_click()
    gen_vault_lock()
    print("All Lumina sound design assets successfully generated!")
