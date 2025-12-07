# sleep_control.talon
# Put Talon into a "sleep" state with our own word: drowse.

drowse:
    # Turn on the built-in "sleep" mode
    mode.enable("sleep")
    # Turn off normal command and dictation grammars
    mode.disable("command")
    mode.disable("dictation")

# (Optional) If you *never* want to use the built-in engine sleep,
# you can neuter the standard phrases so they do nothing:
# go to sleep:
#     skip()
#
# talon sleep:
#     skip()
