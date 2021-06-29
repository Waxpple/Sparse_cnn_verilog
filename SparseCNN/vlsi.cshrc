if ( $?prompt ) then


####a###############################################################
## Cadence                                                         #
####################################################################
	source /usr/cad/cadence/cshrc

###################################################################
# Calibre                                                         #
###################################################################
	source /usr/mentor/CIC/calibre.cshrc
 
###################################################################
# Debussy $ Verdi                                                 #
###################################################################
#	source /usr/spring_soft/CIC/debussy.cshrc 
#	source /usr/spring_soft/CIC/verdi.cshrc 
#	source /usr/cad/cadence/CIC/edi.cshrc
 
###################################################################
# Synopsys                                                        #
###################################################################
#	source /usr/cad/synopsys/cshrc
	source /usr/cad/synopsys/CIC/synthesis.cshrc
	source /usr/cad/synopsys/CIC/license.csh
	source /usr/cad/synopsys/CIC/spyglass.cshrc
	source /usr/cad/synopsys/CIC/primetime.cshrc

###################################################################
# Cadence Formal                                                  #
###################################################################
#	source /usr/cad/cadence/jasper/cur/cshrc


###################################################################
# Innovus                                                         #
###################################################################
	source /home/raid7_4/raid1_1/linux/innovus/CIC/license.cshrc
	source /home/raid7_4/raid1_1/linux/innovus/CIC/innovus.cshrc


#set path=(/usr/cad/synopsys/customexplorer/cur/bin $path)
set path=(/usr/cad/spring_soft/laker/cur/bin $path)

endif
