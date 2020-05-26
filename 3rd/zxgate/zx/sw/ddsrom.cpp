//
// DDS Sine VHDL ROM generator
// Generates a full sine period ROM with
// minimum length for less than 1 LSB error
// and calculates phase accumulator values
//
// Version : 0208
//
// Copyright (c) 2002 Daniel Wallner (dwallner@hem2.passagen.se)
//
// All rights reserved
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// Neither the name of the author nor the names of other contributors may
// be used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Please report bugs to the author, but before you do so, please
// make sure that this is not a derivative work and that
// you have the latest version of this file.
//
// The latest version of this file can be found at:
//	http://hem.passagen.se/dwallner/vhdl.html
//
// Limitations :
//	Can only generate a full period
//
// File history :
//
// 0208 : Original release
//

#include <stdio.h>
#include <math.h>
#include <string>
#include <vector>
#include <iostream>

using namespace std;

#if !(defined(max)) && _MSC_VER
	// VC fix
	#define max __max
#endif

#define m_pi 3.141592653589793

class File
{
public:
	explicit File(const char *fileName, const char *mode)
	{
		m_file = fopen(fileName, mode);
		if (m_file != NULL)
		{
			return;
		}
		string errorStr = "Error opening ";
		errorStr += fileName;
		errorStr += "\n";
		throw errorStr;
	}

	~File()
	{
		fclose(m_file);
	}

	FILE *Handle() { return m_file; };
private:
	FILE				*m_file;
};

int main (int argc, char *argv[])
{
	cerr << "DDS Sine VHDL ROM generator by Daniel Wallner. Ver. 0208\n";

	try
	{
		if (argc != 6)
		{
			cerr << "Usage: ddsrom Fs FOut Width Precision <entity name>\n";
			cerr << "Example:\n";
			cerr << "  ddsrom 50 4.43361875 6 0.001 DDSROM\n\n";
			return -1;
		}

		int result;
		cerr << "Arguments :\n";

		double Fs;
		result = sscanf(argv[1], "%lf", &Fs);
		cerr << " Fs = " << Fs << "\n";

		double FOut;
		result = sscanf(argv[2], "%lf", &FOut);
		cerr << " FOut = " << FOut << "\n";

		unsigned long dWidth;
		result = sscanf(argv[3], "%lu", &dWidth);
		cerr << " Data Width = " << dWidth << "\n";

		double precision;
		result = sscanf(argv[4], "%lf", &precision);
		cerr << " Frequency precision = " << precision << "\n";

		string	outFileName;
		outFileName.assign(argv[5]);

		string outFileNameWE = outFileName + ".vhd";
		File	outFile(outFileNameWE.c_str(), "wt");

		cerr << "\nResults :\n";

		unsigned long aWidth = 1;

		unsigned long	words = 2;
		double	Nmin = pow(2, dWidth) * m_pi;

		while (words < Nmin)
		{
			words <<= 1;
			aWidth++;
		}

		cerr << " Table entries = " << words;
		cerr << "\n Table address width = " << aWidth;

		unsigned long accWidth = 0;
		unsigned C = long(0.5 + 2.0 * FOut / Fs);

		while (precision < fabs(FOut - Fs * C / pow(2, accWidth)))
		{
			accWidth++;
			C = long(0.5 + pow(2, accWidth) * FOut / Fs);
		}

		cerr << "\n Accumulator Width = " << accWidth;
		cerr << "\n Increment = " << C;
		cerr << "\n Actual frequency = " << Fs * C / pow(2, accWidth) << "\n";

		fprintf(outFile.Handle(), "-- This file was created by ddsrom by Daniel Wallner\n");
		fprintf(outFile.Handle(), "\nlibrary IEEE;");
		fprintf(outFile.Handle(), "\nuse IEEE.std_logic_1164.all;");
		fprintf(outFile.Handle(), "\nuse IEEE.numeric_std.all;");
		fprintf(outFile.Handle(), "\n\nentity %s is", outFileName.c_str());
		fprintf(outFile.Handle(), "\n\tport(");
		fprintf(outFile.Handle(), "\n\t\tAddr\t: in std_logic_vector(%d downto 0);", aWidth - 1);
		fprintf(outFile.Handle(), "\n\t\tData\t: out std_logic_vector(%d downto 0)", dWidth - 1);
		fprintf(outFile.Handle(), "\n\t);");
		fprintf(outFile.Handle(), "\nend %s;", outFileName.c_str());
		fprintf(outFile.Handle(), "\n\narchitecture rtl of %s is", outFileName.c_str());
		fprintf(outFile.Handle(), "\n\tsubtype ROM_WORD is std_logic_vector(%d downto 0);", dWidth - 1);
		fprintf(outFile.Handle(), "\n\ttype ROM_TABLE is array(0 to %d) of ROM_WORD;", words - 1);
		fprintf(outFile.Handle(), "\n\tconstant ROM: ROM_TABLE := ROM_TABLE'(");

		unsigned long i;
		for (i = 0; i < words; i++)
		{
			long val;
			val = long(floor(0.5 + (pow(2,dWidth - 1) - 1) * sin(2 * m_pi * i / words)));
			fprintf(outFile.Handle(), "\n\t\tROM_WORD(");
			fprintf(outFile.Handle(), "to_signed(%d, %d)", val, dWidth);
			if (i != words - 1)
			{
				fprintf(outFile.Handle(), "),");
			}
			else
			{
				fprintf(outFile.Handle(), "));");
			}
			fprintf(outFile.Handle(), "\t-- 0x%04X", i);
		}

		fprintf(outFile.Handle(), "\nbegin");
		fprintf(outFile.Handle(), "\n\tData <= ROM(to_integer(unsigned(Addr)));");
		fprintf(outFile.Handle(), "\nend;\n");

		return 0;
	}
	catch (string error)
	{
		cerr << "Fatal: " << error;
	}
	catch (const char *error)
	{
		cerr << "Fatal: " << error;
	}
	return -1;
}
