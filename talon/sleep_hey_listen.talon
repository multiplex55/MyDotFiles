# sleep_hey_listen.talon
# Commands that are allowed WHILE we're in sleep mode.

mode: sleep
-
hey listen:
    # Leave sleep mode and go back to command mode
    mode.disable("sleep")
    mode.enable("command")

echo words:
    mode.disable("sleep")
    mode.disable("command")
    mode.enable("dictation")
