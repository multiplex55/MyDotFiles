# my_wake.talon
# Say "hey listen" to wake Talon and go to command mode.

hey listen:
    speech.enable()
    mode.disable("dictation")
    mode.enable("command")
