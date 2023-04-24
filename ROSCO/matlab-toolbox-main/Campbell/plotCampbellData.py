import sys
import os
import glob
import matplotlib.pyplot as plt
# Local
from linearization import postproMBC, plotCampbell


if len(sys.argv) not in [3,3,4]:
    print(""" 
usage:
    plotCampbellData XLS_OR_CSV [WS_OR_RPM] [sheetname] 

where:
    - XLS_OR_CSV: is an Excel file, or the ModesID CSV file generated by the matlab 
           postprocessing of the linearization.
           The "ModesID" CSV file can have any name, but the remaining csv files
           are assumed to be [Campbell_Points*.csv  and Campbell_OP.csv]
           in the same folder of the "ModesID" csv.

    - WS_OR_RPM: is `ws` or `rpm` (case insensitive), value use for  x-axis

    - sheetname: optional argument to specify the ModesID sheet of the xls file.
""")
    sys.exit(-1)

    
# --- Input handling
xls_or_csv = sys.argv[1]
if len(sys.argv)>=3:
    ws_or_rpm  = sys.argv[2]
else:
    ws_or_rpm  = 'rpm'
if len(sys.argv)>=4:
    sheetname = sys.argv[3]
else:
    sheetname = None
if ws_or_rpm.lower()=='ws':
    sx='WS_[m/s]'
else:
    sx='RotSpeed_[rpm]'

ext     = os.path.splitext(xls_or_csv)[1].lower()
baseDir = os.path.dirname(xls_or_csv)
basename = os.path.splitext(os.path.basename(xls_or_csv))[0]

# --- Read xlsx or csv filse
if ext=='.xlsx':
    print('using Excel file:',xls_or_csv)
    OP, Freq, Damp, UnMapped, ModeData =  postproMBC(xlsFile=xls_or_csv,xlssheet=sheetname)

elif ext=='.csv':
    OP, Freq, Damp, UnMapped, ModeData =  postproMBC(csvModesID=xls_or_csv)

    pass

else:
    raise Exception('Extension should be csv or xlsx, got {} instead.'.format(ext),)

# --- Plot
fig, axes = plotCampbell(OP, Freq, Damp, sx=sx, UnMapped=UnMapped, ylim=None)
figName = os.path.join(baseDir,basename+'_'+ws_or_rpm+'.png')
print('Figure saved to:',figName)
fig.savefig(figName, dpi=300)

#plt.show()
