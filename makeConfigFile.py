#!/usr/bin/python3
""" create .pastaELN.json in home folder of user and return random password """
import sys, os, json, random, string

#.pastaELN.json
if len(sys.argv)<2:
  softwareDir = input('Please enter the path of the PASTA software relative the home: ')
else:
  softwareDir = sys.argv[1]
if len(sys.argv)<3:
  pastaDir = input('Please enter the path of the PASTA DATA relative to the home: ')
else:
  pastaDir = sys.argv[2]
if len(sys.argv)<4:
  password = ''.join(random.choice(string.ascii_letters) for i in range(12))
else:
  password = sys.argv[3]

softwareDir = os.path.expanduser('~')+os.sep+softwareDir
pastaDir = os.path.expanduser('~')+os.sep+pastaDir
content = {}
content['default']     = 'research'
content['links']       = {'research':{\
                        'local':{'user':'admin', 'password':password, 'database':'research', 'path':pastaDir},
                        'remote':{}  }}
content['version']     = 1
content['softwareDir'] = softwareDir+'/Python'
content['userID']      = os.getlogin()
content['extractors']  = {}
content['qrPrinter']   = {}
content['magicTags']   = ['P1','P2','P3','TODO','WAIT','DONE']
content['tableFormat'] = {'x0':{'-label-':'Projects','-default-': [22,6,50,22]},\
                          'measurement':{'-default-': [24,7,23,23,-5,-6,-6,-6]},\
                          'sample':{'-default-': [23,23,23,23,-5]},\
                          'procedure':{'-default-': [20,20,20,40]}}
with open(os.path.expanduser('~')+os.sep+'.pastaELN.json','w') as fOut:
  fOut.write(json.dumps(content, indent=2) )
  print('dumbed')
print('dumbed')

content ='[Desktop Entry]\nName=PASTA ELN\nComment=PASTA electronic labnotebook\n'
content+='Exec='+os.path.expanduser('~')+os.sep+softwareDir+"/install.sh"
content+='Icon='+os.path.expanduser('~')+os.sep+softwareDir+"/pasta.png"
content+='Terminal=false\nType=Application\nCategories=Utility;Application;\n'
try:
  with open(os.path.expanduser('~')+os.sep+'Desktop/pastaELN.desktop','w') as fOut:
    fOut.write(content)
    os.chmod(os.path.expanduser('~')+os.sep+'Desktop/pastaELN.desktop', 0o777)
except:
  pass
try:
  with open(os.path.expanduser('~')+os.sep+'.local/share/applications/pastaELN.desktop','w') as fOut:
    fOut.write(content)
    os.chmod(os.path.expanduser('~')+os.sep+'.local/share/applications/pastaELN.desktop', 0o777)
except:
  pass

# end
print(password)
