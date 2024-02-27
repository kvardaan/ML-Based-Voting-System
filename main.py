from flask import Flask, render_template, request
import random

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/submit_registration', methods=['POST'])
def submit_registration():
    # Handle form submission logic here
    full_name = request.form.get('fullName')
    adhaar_id = request.form.get('AdhaarId')
    # Generate Voter ID Number
    voter_id = generate_voter_id()
    return f"Form submitted successfully!<br>Full Name: {full_name}<br>Adhaar ID: {adhaar_id}<br>Voter ID: {voter_id}"

def generate_voter_id():
    # Generate a random 8-digit number
    generated_numbers = set()
    random_number = str(10000000 + random.randint(0, 90000000))
    if random_number not in generated_numbers:
        generated_numbers.add(random_number)
        return random_number

if __name__ == '__main__':
    app.run(debug=True)
