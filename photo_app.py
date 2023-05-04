from kivy.app import App
from kivy.lang import Builder
from kivy.uix.image import Image
from kivy.clock import Clock
from kivy.uix.label import Label
from kivy.uix.screenmanager import ScreenManager, Screen, WipeTransition
from paho.mqtt.client import Client
import json
import os
import get_google_album 

MQTT_CLIENT_ID = "photo_app"
MQTT_BROKER_HOST = "localhost"
MQTT_BROKER_PORT = 1883
MQTT_BROKER_KEEP_ALIVE_SECS = 60

TOPIC_OAUTH_CREDS_RECEIVED = 'lamp/set_oauth_creds'
TOPIC_ACCT_CREDS_RECEIVED = 'lamp/set_acct_creds'
TOPIC_SLIDESHOW_SETTINGS_RECEIVED = 'lamp/set_slideshow_settings'
TOPIC_SLIDESHOW_STATE_RECEIVED = 'lamp/set_slideshow_state'

IMGS_DIR = 'images/'

class NoAuthWindow(Screen):
    pass

class HomeWindow(Screen):
    pass

class SlideShowWindow(Screen):
    pass

class WindowManager(ScreenManager):
    pass

class PhotoApp(App):
    _received_oauth_creds = False
    _received_acct_creds = False 

    album_id = None
    album = 'None'
    speed = '5'
    animation = 'in_quad'

    slideshow_state = 'stop'

    def build(self):
        global main
        main = WindowManager(transition=WipeTransition())
        return main 

    def on_start(self):
        print(main.ids)
        self.mqtt = Client(client_id=MQTT_CLIENT_ID)
        self.mqtt.enable_logger()
        self.mqtt.on_connect = self.on_connect
        self.mqtt.connect(MQTT_BROKER_HOST, port=MQTT_BROKER_PORT,
                          keepalive=MQTT_BROKER_KEEP_ALIVE_SECS)
        self.mqtt.loop_start()

        self.home_window_trigger = Clock.create_trigger(self.go_to_home_window)
        self.slideshow_window_trigger = Clock.create_trigger(self.go_to_slideshow_window)

    def on_connect(self, client, userdata, flags, rc):
        self.mqtt.message_callback_add(TOPIC_OAUTH_CREDS_RECEIVED,
                                       self.receive_oauth_creds)
#        self.mqtt.message_callback_add(TOPIC_ACCT_CREDS_RECEIVED,
#                                       self.receive_acct_creds)
        self.mqtt.message_callback_add(TOPIC_SLIDESHOW_SETTINGS_RECEIVED,
                                       self.receive_slideshow_settings)
        self.mqtt.message_callback_add(TOPIC_SLIDESHOW_STATE_RECEIVED,
                                       self.receive_slideshow_state)

        self.mqtt.subscribe(TOPIC_OAUTH_CREDS_RECEIVED, qos=1)
#        self.mqtt.subscribe(TOPIC_ACCT_CREDS_RECEIVED, qos=1) 
        self.mqtt.subscribe(TOPIC_SLIDESHOW_SETTINGS_RECEIVED, qos=1)
        self.mqtt.subscribe(TOPIC_SLIDESHOW_STATE_RECEIVED, qos=1)

    def receive_oauth_creds(self, client, userdata, message):
        new_oauth_creds = json.loads(message.payload.decode('utf-8').replace(u"\u00A0", " "))
        with open('token.json', 'w') as f:
            json.dump(new_oauth_creds, f)

        _received_oauth_creds = True

        self.home_window_trigger()

    def receive_slideshow_settings(self, client, userdata, message):
        new_slideshow_settings = json.loads(message.payload.decode('utf-8').replace(u"\u00A0", " "))
        
        self.album_id = new_slideshow_settings['album_id']
        self.album = new_slideshow_settings['album']
        self.speed = new_slideshow_settings['speed']
        self.animation = new_slideshow_settings['animation']

        self.update_settings_ui()

    def receive_slideshow_state(self, client, userdata, message):
        new_slideshow_state = json.loads(message.payload.decode('utf-8'))
        new_slideshow_state = new_slideshow_state['state'] 

        if new_slideshow_state == "stop" and new_slideshow_state != self.slideshow_state:
            self.slideshow_event.cancel()
            self.slideshow_state = new_slideshow_state 
            self.home_window_trigger()

        elif new_slideshow_state == "play" and new_slideshow_state != self.slideshow_state:
            if self.album_id == None or self.album_id == '':
                print("NO Album Specified") 

            else:
                print("album id specified: " + self.album_id)
                self.slideshow_state = new_slideshow_state
                Clock.schedule_once(lambda dt: self.clear_image_directory(), 0.1)
                print("fetching and downloading images...")
                Clock.schedule_once(lambda dt: self.fetch_and_download_google_photos(), 0.1)
                Clock.schedule_once(lambda dt: self.setup_slideshow(), 0.1)
                self.slideshow_window_trigger()
    
    def go_to_home_window(self, dt):
        main.current = 'home' 

    def go_to_slideshow_window(self, dt):
        main.current = 'slideshow'

    def update_settings_ui(self):
        main.ids.album_selected.text = 'Album: ' + self.album
        main.ids.slideshow_speed.text = 'Speed: ' + self.speed
        main.ids.slideshow_animation.text = 'Animation: ' + self.animation

    def clear_image_directory(self):
        imgs_list = os.listdir(IMGS_DIR)
        number_of_imgs = len(imgs_list)

        for i in range(number_of_imgs):
            os.remove(IMGS_DIR + imgs_list[i])

    def fetch_and_download_google_photos(self):
        album_id = self.album_id
        get_google_album.start(album_id)
        print("images downloaded")

    def setup_slideshow(self):
        print('setting up slideshow')
        slideshow = main.ids.slideshow
        slideshow.clear_widgets()

        imgs_list = os.listdir(IMGS_DIR)
        number_of_imgs = len(imgs_list)

        print(imgs_list)
        slideshow.direction = 'right'
        slideshow.loop = True
        slideshow.anim_type = self.animation
        for i in range(number_of_imgs):
            image = Image(source=IMGS_DIR + imgs_list[i], keep_ratio=True)
            slideshow.add_widget(image)

        print(slideshow.slides)
        slideshow.load_slide(slideshow.slides[0])

        self.slideshow_event = Clock.schedule_interval(lambda dt: self.go_to_next_slide(slideshow), int(self.speed))

    def go_to_next_slide(self, slideshow):
        slideshow.load_next(mode='next') 

#    def receive_acct_creds(self, client, userdata, message):
#        new_acct_creds = json.loads(message.payload.decode('utf-8'))
#        with open('acct.json', 'w') as f:
#            json.dump(new_acct_creds, f)
#
#        _received_acct_creds = True

'''
    def build(self):
        wimg = Image(source='images/final-proj-demo.png') 
        return wimg
'''

