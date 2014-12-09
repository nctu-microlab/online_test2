#include <REG_MPC82G516.H>

// P1(0~3) -> bitmap col select(0~3)
// P2(0~7) -> bitmap row 8~1
// P1.7 -> 7seg C1
// P0(0~3) -> 7seg SE1~4
// P3(7~0) -> X3 X2 X1 X0 Y3 Y2 Y1 Y0

/*
00000000
01110111
00010101
01110111
01000001
01110001
00000000
00000000
*/
const unsigned char bitmap[8] = {
	~0x00,
	~0x5C,
	~0x54,
	~0x74,
	~0x00,
	~0x70,
	~0x50,
	~0x7C
};
const unsigned char keymap[16] = {0, 0, 1, 0, 2, 0, 0, 0, 3, 0};

char remain_flash = 0; // To be display on 7seg

void display_id();
void display_remain();
void scan_keyboard();
void go();

void main() {
	while(1) {
		display_id();
		display_remain();
		scan_keyboard();
	}
}

void go() {
	unsigned short delay;
	
	while(remain_flash--) {
		for(delay = 0; delay < 250; delay++)
			display_id();
		
		P2 = ~0;
		for(delay = 0; delay < 60000; delay++);
		
		display_remain();
	}
	
	remain_flash = 0;
}

void scan_keyboard() {
	unsigned char i, scan_result, scanned_number;
	for(i = 0; i < 3; i++) {
		P3 = 0xFF ^ (1 << 4 << i);
		scan_result = (~P3 & 0x0F);
		
		if(scan_result != 0) {
			scanned_number = i*4 + keymap[scan_result];
			
			if(scanned_number == 10)
				go();
			else if(scanned_number <= 9)
				remain_flash = scanned_number;
			
			return;
		}
	}
}

void display_remain() {
	P0 = remain_flash;
}

void display_id() {
	unsigned char i, j;
	
	for(i = 0; i < 8; i++) {
		P1 = i;
		P2 = bitmap[i];
		
		for(j = 0; j < 250; j++); // For Delay
	}
}

