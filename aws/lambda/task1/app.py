from flask import Flask, request, redirect, url_for, render_template_string

app = Flask(__name__)
last_word = None

@app.route("/", methods=["GET", "POST"])
def index():
    global last_word
    if request.method == "POST":
        last_word = request.form.get("word")
        return redirect(url_for("index"))
    return render_template_string("""
        <h1>Hi! Your last word is: {{ word }}</h1>
        <form method="post">
            <input type="text" name="word" placeholder="Enter a word" required>
            <input type="submit" value="Send">
        </form>
    """, word=last_word)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000)
