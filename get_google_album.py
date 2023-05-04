import os
import requests
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# credentials necessary for oauth authentication
CLIENT_FILE = 'acct.json'
SCOPES = ['https://www.googleapis.com/auth/photoslibrary.readonly']

## load in existing API credentials and scope - IF SCOPES ARE ADDED OR REMOVED DELETE THE EXISTING TOKEN.JSON FILE
#creds = None
#if os.path.exists('token.json'):
#    creds = Credentials.from_authorized_user_file('token.json', SCOPES)
#
## get API credentials if none exist or they have expired
#if not creds or not creds.valid:
#    if creds and creds.expired and creds.refresh_token:
#        creds.refresh(Request())
#    else:
#        flow = InstalledAppFlow.from_client_secrets_file(CLIENT_FILE, SCOPES)
#        creds = flow.run_local_server(port=0)
#    with open('token.json', 'w') as token:
#        token.write(creds.to_json())

def get_album_contents(service, albumID):
    nextPageToken = 'p'

    while nextPageToken != '':
        if nextPageToken == 'p':
            nextPageToken = ''

        pageSize = 20

        # search for media items is an HTTP POST request and requries a body attribute
        requestBody = {"albumId": albumID,
                       "pageSize": pageSize, "pageToken": nextPageToken}
        response = service.mediaItems().search(body=requestBody).execute()

        mediaItems = response.get("mediaItems", [])
        nextPageToken = response.get("nextPageToken", "")

        baseUrls = []
        filenames = []
        for mediaItem in mediaItems:
            baseUrls.append(mediaItem['baseUrl'])
            filenames.append(mediaItem['filename'])

        download_photos(baseUrls, filenames)


def download_photos(baseUrls, filenames):
    for i in range(len(baseUrls)):
        url = baseUrls[i]
        filename = filenames[i]

        response = requests.get(
            url=url, params={"w": 240, "h": 320, "d": True})

        destinationFolder = './images/'

        with open(os.path.join(destinationFolder, filename), 'wb') as f:
            f.write(response.content)
            f.close()

def start(albumID):
    # load in existing API credentials and scope - IF SCOPES ARE ADDED OR REMOVED DELETE THE EXISTING TOKEN.JSON FILE
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    
    # get API credentials if none exist or they have expired
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(CLIENT_FILE, SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    with build('photoslibrary', 'v1', credentials=creds, static_discovery=False) as service:
        get_album_contents(service, albumID)
    
