/* Quartus Prime Version 24.1.0 Build 115 03/21/2024 SC Pro Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Cfg)
		Device PartName(10AS066N3F40) Path("/home/ubuntuaspiretank/p4p/P4P-Team44/NewNewProject/hw/output_files/") File("top.sof") MfrSpec(OpMask(1));
	P ActionCode(Ign)
		Device PartName(SOCVHPS) MfrSpec(OpMask(0));
	P ActionCode(Ign)
		Device PartName(1_BIT_TAP) MfrSpec(OpMask(0));
	P ActionCode(Ign)
		Device PartName(5M1270ZF324) MfrSpec(OpMask(0));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
