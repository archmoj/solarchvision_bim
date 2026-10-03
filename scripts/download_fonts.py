import requests

dirOut = '../app/src/solarchvision_bim/data/font/'

def downloadFonts(baseUrl, allNames) :
    for name in allNames :
        url = baseUrl + name
        print(url)
        req = requests.get(url, allow_redirects=True)
        open(dirOut + name, 'wb').write(req.content)

downloadFonts(
    'https://raw.githubusercontent.com/microsoft/HoloLens-Art-Recommendations/master/MR_ComputerVision/Assets/HoloToolkit/UX/Fonts/',
    [
        #'selawkb.ttf',
        #'selawkl.ttf',
        #'selawksl.ttf'
        #'selawksb.ttf',
        'selawk.ttf'
    ]
)

def downloadLicense(baseUrl, name) :
    url = baseUrl + name
    print(url)
    req = requests.get(url, allow_redirects=True)
    open(dirOut + name, 'wb').write(req.content)

downloadLicense(
    'https://raw.githubusercontent.com/microsoft/Selawik/refs/heads/master/',
    'LICENSE.txt'
)


