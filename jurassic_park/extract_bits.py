def checkIfCorrect(bitStr, lenBits):
	if lenBits == 9:
		return bitStr.startswith("0")
	return True

def parse_and_print_bits(lines):
	current_byte = None
	bit_index = 0
	accumulated_bits = []
	commands_lengths = set()

	for line in lines:
		line = line.strip()

		if line.startswith('READ'):
			current_byte = format(int("0x"+line.split('<-')[1].strip()[:2], 16), '08b')
			#print(f"READ {current_byte}")

		elif line.startswith('74 ---'):
			argument = int("0x"+line.split('74:')[1].split(',')[0].strip(), 16)
			if argument != 0 and current_byte is not None:
				accumulated_bits.append(current_byte[bit_index])
				bit_index = (bit_index + 1) & 7

		elif line.startswith('WRITE'):
			lenBits = len(accumulated_bits)
			if lenBits > 0:
				commands_lengths.add(lenBits)
				bitStr = ''.join(accumulated_bits)
				if not checkIfCorrect(bitStr, lenBits):
					print("!!!error!!!")
				print(f"{bitStr} ({len(accumulated_bits)} bits)")
			print("  " + line.split("---")[0])
			accumulated_bits = []
			
	print(f"Commands lengths: {commands_lengths}")

with open("jp_unpack_60C8_72CB.txt", "rt") as f:
	l = f.readlines()
	parse_and_print_bits(l)