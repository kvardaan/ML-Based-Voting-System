from flask import Flask, render_template
from pymongo import MongoClient

app = Flask(__name__)
client = MongoClient('mongodb+srv://anurag:anurag@cluster0.cynvddz.mongodb.net/')
db = client['votingsystem']
collection = db['votes']
print("database connected")
# Sample data
sample_data = [
    {"party": "Party A", "candidate": "Candidate 1", "votes": 150},
    {"party": "Party A", "candidate": "Candidate 2", "votes": 120},
    {"party": "Party B", "candidate": "Candidate 3", "votes": 180},
    {"party": "Party B", "candidate": "Candidate 4", "votes": 90},
    {"party": "Party C", "candidate": "Candidate 5", "votes": 200},
    {"party": "Party C", "candidate": "Candidate 6", "votes": 210},
]

# Insert sample data if the collection is empty
if collection.count_documents({}) == 0:
    collection.insert_many(sample_data)

print("data inserted")

# Route for the dashboard
@app.route('/')

def dashboard():
    votes = list(collection.find())
    candidates = {}
    for vote in votes:
        candidate_party = f"{vote['candidate']} ({vote['party']})"
        if candidate_party in candidates:
            candidates[candidate_party] += vote['votes']
        else:
            candidates[candidate_party] = vote['votes']
    print(candidates)  # Add this line for debugging
    return render_template('dashboard.html', candidates=candidates)

if __name__ == '__main__':
    app.debug = True
    app.run()

