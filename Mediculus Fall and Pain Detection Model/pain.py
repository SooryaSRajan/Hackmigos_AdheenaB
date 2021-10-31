import torch
import torch.nn as nn
from PIL import Image
from torchvision import transforms
import torch.nn.functional as F
import cv2
import requests
class NN(nn.Module):
    def __init__(self):
        super(NN, self).__init__()
        self.layer1 = nn.Sequential(
        nn.Conv2d(1, 64, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.Conv2d(64, 64, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.MaxPool2d(kernel_size=2, stride=2))
        self.layer2 = nn.Sequential(
        nn.Conv2d(64, 128, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.Conv2d(128, 128, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.MaxPool2d(kernel_size=2, stride=2))
        self.layer3 = nn.Sequential(
        nn.Conv2d(128, 256, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.Conv2d(256, 256, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.Conv2d(256, 256, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.MaxPool2d(kernel_size=2, stride=2))
        self.layer4 = nn.Sequential(
        nn.Conv2d(256, 512, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.Conv2d(512, 512, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.Conv2d(512, 512, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.MaxPool2d(kernel_size=2, stride=2))
        self.layer5 = nn.Sequential(
        nn.Conv2d(512, 512, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.Conv2d(512, 512, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.Conv2d(512, 512, kernel_size=3, stride=1, padding=1),
        nn.ReLU(),
        nn.MaxPool2d(kernel_size=2, stride=2))
        self.drop_out = nn.Dropout()
        self.fc1 = nn.Linear(7 * 7 * 512, 1000)
        self.fc2 = nn.Linear(1000, 2)
    def forward(self, x):
        out = self.layer1(x)
        out = self.layer2(out)
        out = self.layer3(out)
        out = self.layer4(out)
        out = self.layer5(out)
        out = out.reshape(out.size(0), -1)
        out = self.drop_out(out)
        out = F.relu(self.fc1(out))
        out = self.fc2(out)
        return out



def painmodel():
    img= Image.open('processed_image.png')
    model = NN()
    model.load_state_dict(torch.load("pain_detection_nn5.pth",map_location=torch.device('cpu')))
    data_transform = transforms.Compose(
        [transforms.ToTensor(),
        transforms.Resize((224,224)),
        transforms.Normalize((0.5,), (0.5,)),
        transforms.Grayscale(num_output_channels=1)
        ]
    )

    img= data_transform(img)
    #img = Variable(img, requires_grad=True)
    img = img.unsqueeze(0)
    
    output= model(img)
    value, index = torch.max(output, 1)

    return index
def preprocess(img):
    try:
        face_cascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
        faces = face_cascade.detectMultiScale(img, 1.1, 4)
        x, y, w, h = faces[0]
        img2=img[y:y+h,x:x+w ]
        return 0
    except:
        return 1
    
    cv2.imwrite('processed_image.png',img2)

def send_latlong():
    lat= 11.0089
    long= 76.9595
    jwt_token='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI4OXhxQCFPI045OHBuIUAqQCEjQkBeQFRJTiZPIUAzaTIxMzduMTJpVEkhQCZUI05AISIsImlhdCI6MTYzNTY4MzU5NH0.6t6NzF9pNqNgUjJKX4Vz-mD1JY6jny2JPyPrZa9Ec3o'
    url='https://emergency-io.herokuapp.com/coordinates'
    resp=requests.post(
        url, 
        json={
                "latitude":lat,
                "longitude":long
            },
        headers={"jwt-token":jwt_token}

    )
    print(resp.content)

def pain_detection(img):
    x=preprocess(img)
    if x==0:
        index=painmodel()
        if index==0:
            return False
        else:
            send_latlong()
            return True
    else:
        return False
        
