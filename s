[1mdiff --git a/app.py b/app.py[m
[1mindex 71283e8..815d6fc 100644[m
[1m--- a/app.py[m
[1m+++ b/app.py[m
[36m@@ -1,13 +1,19 @@[m
 import pymongo[m
[31m-from flask import Flask, render_template, request[m
[32m+[m[32mfrom flask import Flask, render_template, request, redirect, url_for[m[41m[m
 from datetime import datetime[m
 import random[m
 import os[m
[32m+[m[32mfrom random import randint[m[41m[m
 from werkzeug.utils import secure_filename[m
 [m
 app = Flask(__name__)[m
[31m-mongoDB_connection = pymongo.MongoClient("mongodb+srv://<username>:<password>@cluster0.cynvddz.mongodb.net/")[m
[32m+[m[32mapp.secret_key = b'_5#y2L"F4Q8z\n\xec]/'[m[41m[m
[32m+[m[41m[m
[32m+[m[32mmongoDB_connection = pymongo.MongoClient("mongodb+srv://admin:ad_min@cluster0.cynvddz.mongodb.net/")[m[41m[m
 database = mongoDB_connection["voting_system"][m
[32m+[m[32mvoters_collection = database["voters"][m[41m[m
[32m+[m[32mcandidates_collection = database["candidates"][m[41m[m
[32m+[m[32mvotes_collection = database["votes"][m[41m[m
 [m
 class Voter:[m
     def __init__(self, voter_id, full_name, adhaar_id, face_data, fingerprint_data):[m
[36m@@ -36,16 +42,23 @@[m [mdef voter_registration():[m
 def candidate_registration():[m
     return render_template('candidate_registration.html')[m
 [m
[32m+[m[32m@app.route('/voting')[m[41m[m
[32m+[m[32mdef voting():[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    candidates = candidates_collection.find()  # Fetch all candidates from the database[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    return render_template('voting.html', candidates=candidates)[m[41m[m
 [m
 @app.route('/voting_results')[m
 def voting_results():[m
[31m-    candidates_data = dashboard()[m
[32m+[m[32m    candidates_data, colors = dashboard()[m[41m[m
 [m
     # Check if there are no votes[m
[31m-    if candidates_data is None:[m
[31m-        return render_template('voting_results.html', candidates=None)  # Render the template with no votes[m
[32m+[m[32m    if not candidates_data:[m[41m[m
[32m+[m[32m        return render_template('voting_results.html', candidates=None, backgroundColors=None)  # Render the template with no votes[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    return render_template('voting_results.html', candidates=candidates_data, backgroundColors=colors)  # Render the template with voting results[m[41m[m
 [m
[31m-    return render_template('voting_results.html', candidates=candidates_data)  # Render the template with voting results[m
 [m
 [m
 @app.route('/submit_voter_registration', methods=['POST'])[m
[36m@@ -58,7 +71,7 @@[m [mdef submit_voter_registration():[m
         voter_id = generate_voter_id()[m
 [m
         # Save the generated voter ID to MongoDB for voters[m
[31m-        voters_collection = database["voters"][m
[32m+[m[41m[m
         new_voter = Voter(voter_id, full_name, adhaar_id, face_data, fingerprint_data)[m
         voters_collection.insert_one(new_voter.__dict__)[m
 [m
[36m@@ -77,16 +90,16 @@[m [mdef submit_candidate_registration():[m
     symbol = request.files['symbol'][m
 [m
     # Generate Voter ID Number for candidate (not necessary but kept for consistency)[m
[31m-    voter_id = generate_voter_id()[m
[32m+[m[32m    candidate_id = generate_voter_id()[m[41m[m
 [m
     # Save the candidate information to MongoDB for candidates[m
[31m-    candidates_collection = database["candidates"][m
[32m+[m[41m[m
     symbol_path = save_symbol(symbol)[m
[31m-    new_candidate = Candidate(voter_id, full_name, party_name, symbol_path)[m
[32m+[m[32m    new_candidate = Candidate(candidate_id, full_name, party_name, symbol_path)[m[41m[m
     candidates_collection.insert_one(new_candidate.__dict__)[m
 [m
     # Render the display template directly with the generated voter ID[m
[31m-    return render_template('display_candidate_info.html', voter_id=voter_id, full_name=full_name, party_name=party_name, symbol_path=new_candidate.symbol_path)[m
[32m+[m[32m    return render_template('display_candidate_info.html', candidate_id=candidate_id, full_name=full_name, party_name=party_name, symbol_path=new_candidate.symbol_path)[m[41m[m
 [m
 def generate_voter_id():[m
     # Get the current timestamp to add to the voter ID[m
[36m@@ -110,22 +123,67 @@[m [mdef save_symbol(symbol_file):[m
     symbol_file.save(symbol_path)[m
     return symbol_path[m
 [m
[31m-# Dashboard Work[m
 def dashboard():[m
[31m-    votes_collection = database["votes"][m
[31m-    # if votes_collection.count_documents({}) == 0:[m
[31m-    #     votes_collection.insert_many(sample_data)[m
[32m+[m[32m    candidates_data = {}[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    # Fetch all candidates from the candidates collection[m[41m[m
[32m+[m[32m    candidates = list(candidates_collection.find())[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    # Generate random colors for each candidate in hexadecimal format[m[41m[m
[32m+[m[32m    colors = ['#%06x' % random.randint(0, 0xFFFFFF) for _ in range(len(candidates))][m[41m[m
 [m
[32m+[m[32m    # Iterate over each candidate and initialize their vote count[m[41m[m
[32m+[m[32m    for candidate in candidates:[m[41m[m
[32m+[m[32m        candidate_party = f"{candidate['name']} ({candidate['party_name']})"[m[41m[m
[32m+[m[32m        candidates_data[candidate_party] = 0[m[41m[m
 [m
[32m+[m[32m    # Fetch all votes from the votes collection[m[41m[m
     votes = list(votes_collection.find())[m
[31m-    candidates = {}[m
[32m+[m[41m[m
[32m+[m[32m    # Iterate over each vote and aggregate the vote count for each candidate[m[41m[m
     for vote in votes:[m
[31m-        candidate_party = f"{vote['candidate']} ({vote['party']})"[m
[31m-        if candidate_party in candidates:[m
[31m-            candidates[candidate_party] += vote['votes'][m
[31m-        else:[m
[31m-            candidates[candidate_party] = vote['votes'][m
[31m-    return candidates  # Return the dictionary containing candidate data[m
[32m+[m[32m        candidate_id = vote['candidate_id'][m[41m[m
[32m+[m[32m        candidate = candidates_collection.find_one({'candidate_id': candidate_id})[m[41m[m
[32m+[m[32m        if candidate:[m[41m[m
[32m+[m[32m            candidate_party = f"{candidate['name']} ({candidate['party_name']})"[m[41m[m
[32m+[m[32m            if candidate_party in candidates_data:[m[41m[m
[32m+[m[32m                candidates_data[candidate_party] += 1[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    return candidates_data, colors  # Return the dictionary containing candidate data and list of color strings[m[41m[m
[32m+[m[41m[m
[32m+[m[41m[m
[32m+[m[41m[m
[32m+[m[32m@app.route('/submit_vote', methods=['POST'])[m[41m[m
[32m+[m[32mdef submit_vote():[m[41m[m
[32m+[m[32m    name = request.form.get('name')[m[41m[m
[32m+[m[32m    adhaar_id = request.form.get('adhaarId')[m[41m[m
[32m+[m[32m    voter_id = request.form.get('voterId')[m[41m[m
[32m+[m[32m    candidate_id = request.form.get('candidate')[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    # Verify the voter and candidate[m[41m[m
[32m+[m[32m    voter = voters_collection.find_one({'voter_id': voter_id, 'adhaar_id': adhaar_id, 'fullName': name})[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    candidate = candidates_collection.find_one({'candidate_id': candidate_id})[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    if not voter:[m[41m[m
[32m+[m[32m        return redirect(url_for('voting', message='Invalid voter details'))[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    if not candidate:[m[41m[m
[32m+[m[32m        return redirect(url_for('voting', message='Invalid candidate'))[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    # Connect to the votes collection[m[41m[m
[32m+[m[32m    votes_collection = database["votes"][m[41m[m
[32m+[m[41m[m
[32m+[m[32m    # Insert the vote into the votes collection[m[41m[m
[32m+[m[32m    vote_data = {[m[41m[m
[32m+[m[32m        'voter_id': voter_id,[m[41m[m
[32m+[m[32m        'candidate_id': candidate_id,[m[41m[m
[32m+[m[32m        'timestamp': datetime.now()[m[41m[m
[32m+[m[32m    }[m[41m[m
[32m+[m[32m    votes_collection.insert_one(vote_data)[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    # Redirect back to the voting page with a message[m[41m[m
[32m+[m[32m    return redirect(url_for('voting', message='Vote submitted successfully'))[m[41m[m
 [m
 [m
 if __name__ == '__main__':[m
[1mdiff --git a/static/symbols/1.jpg b/static/symbols/1.jpg[m
[1mnew file mode 100644[m
[1mindex 0000000..89332a0[m
Binary files /dev/null and b/static/symbols/1.jpg differ
[1mdiff --git a/static/symbols/VK.jpg b/static/symbols/VK.jpg[m
[1mnew file mode 100644[m
[1mindex 0000000..fd96fc0[m
Binary files /dev/null and b/static/symbols/VK.jpg differ
[1mdiff --git a/templates/display_candidate_info.html b/templates/display_candidate_info.html[m
[1mindex 2e4b22f..8bb4d5b 100644[m
[1m--- a/templates/display_candidate_info.html[m
[1m+++ b/templates/display_candidate_info.html[m
[36m@@ -8,7 +8,7 @@[m
 <body>[m
     <h1>Candidate Information</h1>[m
 [m
[31m-    <p><strong>Candidate ID:</strong> {{ voter_id }}</p>[m
[32m+[m[32m    <p><strong>Candidate ID:</strong> {{ candidate_id }}</p>[m[41m[m
     <p><strong>Candidate Name:</strong> {{ full_name }}</p>[m
     <p><strong>Party Name:</strong> {{ party_name }}</p>[m
     <p><strong>Symbol Path:</strong> {{ symbol_path }}</p>[m
[1mdiff --git a/templates/index.html b/templates/index.html[m
[1mindex 79a06d1..47619d9 100644[m
[1m--- a/templates/index.html[m
[1m+++ b/templates/index.html[m
[36m@@ -9,18 +9,20 @@[m
     <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>[m
 </head>[m
 <body>[m
[31m-<div class="topnav" id="myTopnav">[m
[31m-    <a {% block homeActive %}{% endblock %} href="/" class="active">Home </a>[m
[31m-    <a {% block votingActive %}{% endblock %} href="/">Voting</a>[m
[31m-    <a {% block voter_registrationActive %}{% endblock %} href="{{ url_for('voter_registration') }}">Voter Registration</a>[m
[31m-    <a {% block candidate_registrationActive %}{% endblock %} href="{{ url_for('candidate_registration') }}">Candidate Registration</a>[m
[31m-    <a href="javascript:void(0);" class="icon" onclick="myFunction()">[m
[31m-    <i class="fa fa-bars"></i>[m
[31m-  </a>[m
[31m-</div>[m
[32m+[m[32m    <div class="topnav" id="myTopnav">[m[41m[m
[32m+[m[32m        <a {% block homeActive %}{% endblock %} href="/" class="active">Home</a>[m[41m[m
[32m+[m[32m        <a {% block votingActive %}{% endblock %} href="{{ url_for('voting') }}">Voting</a>[m[41m[m
[32m+[m[32m        <a {% block voter_registrationActive %}{% endblock %} href="{{ url_for('voter_registration') }}">Voter Registration</a>[m[41m[m
[32m+[m[32m        <a {% block candidate_registrationActive %}{% endblock %} href="{{ url_for('candidate_registration') }}">Candidate Registration</a>[m[41m[m
[32m+[m[32m        <a href="javascript:void(0);" class="icon" onclick="myFunction()">[m[41m[m
[32m+[m[32m            <i class="fa fa-bars"></i>[m[41m[m
[32m+[m[32m        </a>[m[41m[m
[32m+[m[32m    </div>[m[41m[m
 [m
     <div class="container mt-4">[m
[31m-        {% block content %}{% endblock %}[m
[32m+[m[32m        {% block content %}[m[41m[m
[32m+[m[32m        <!-- This is where the content from different pages will be inserted -->[m[41m[m
[32m+[m[32m        {% endblock %}[m[41m[m
     </div>[m
 [m
     <footer>[m
[36m@@ -29,16 +31,15 @@[m
         </div>[m
     </footer>[m
 [m
[31m-    <!-- Your JavaScript files here -->[m
[31m-<script>[m
[31m-    function myFunction() {[m
[31m-        var x = document.getElementById("myTopnav");[m
[31m-        if (x.className === "topnav") {[m
[31m-            x.className += " responsive";[m
[31m-        } else {[m
[31m-            x.className = "topnav";[m
[32m+[m[32m    <script>[m[41m[m
[32m+[m[32m        function myFunction() {[m[41m[m
[32m+[m[32m            var x = document.getElementById("myTopnav");[m[41m[m
[32m+[m[32m            if (x.className === "topnav") {[m[41m[m
[32m+[m[32m                x.className += " responsive";[m[41m[m
[32m+[m[32m            } else {[m[41m[m
[32m+[m[32m                x.className = "topnav";[m[41m[m
[32m+[m[32m            }[m[41m[m
         }[m
[31m-    }[m
[31m-</script>[m
[32m+[m[32m    </script>[m[41m[m
 </body>[m
 </html>[m
[1mdiff --git a/templates/voter_registration.html b/templates/voter_registration.html[m
[1mindex 4343236..f4a3d29 100644[m
[1m--- a/templates/voter_registration.html[m
[1m+++ b/templates/voter_registration.html[m
[36m@@ -19,6 +19,4 @@[m
         <button type="submit" value="Submit" style="font-weight: bold; font-size: 14px">Submit</button>[m
     </form>[m
 [m
[31m-    <!-- Include the same pop-up container and JavaScript code for the pop-up -->[m
[31m-    <!-- ... (Copy the pop-up container and JavaScript code) -->[m
 {% endblock %}[m
\ No newline at end of file[m
[1mdiff --git a/templates/voting.html b/templates/voting.html[m
[1mnew file mode 100644[m
[1mindex 0000000..ba8b0fb[m
[1m--- /dev/null[m
[1m+++ b/templates/voting.html[m
[36m@@ -0,0 +1,43 @@[m
[32m+[m[32m{% extends 'index.html' %}[m
[32m+[m
[32m+[m[32m{% block content %}[m
[32m+[m[32m<div class="container mt-4">[m
[32m+[m[32m    <form action="/submit_vote" method="post">[m
[32m+[m[32m        <h3>Cast your Vote</h3>[m
[32m+[m
[32m+[m[32m        <label for="name">Enter Your Name</label>[m
[32m+[m[32m        <input type="text" id="name" name="name" required>[m
[32m+[m
[32m+[m[32m        <label for="adhaarId">Enter Adhaar ID</label>[m
[32m+[m[32m        <input type="text" id="adhaarId" name="adhaarId" required>[m
[32m+[m
[32m+[m[32m        <label for="voterId">Enter Voter ID</label>[m
[32m+[m[32m        <input type="text" id="voterId" name="voterId" required>[m
[32m+[m
[32m+[m[32m        <label for="candidate">Choose Candidate</label>[m
[32m+[m[32m        <select id="candidate" name="candidate" required>[m
[32m+[m[32m            <option value="" disabled selected>Select a candidate</option>[m
[32m+[m[32m            {% for candidate in candidates %}[m
[32m+[m[32m                <option value="{{ candidate.candidate_id }}">{{ candidate.name }} - {{ candidate.party_name }}[m
[32m+[m[32m                    {% if candidate.symbol_path %}[m
[32m+[m[32m                        <img src="{{ candidate.symbol_path }}" alt="Symbol" height="50">[m
[32m+[m[32m                    {% endif %}[m
[32m+[m[32m                </option>[m
[32m+[m[32m            {% endfor %}[m
[32m+[m[32m        </select><br><br>[m
[32m+[m
[32m+[m[32m        <input type="submit" value="Submit Vote">[m
[32m+[m[32m    </form>[m
[32m+[m[32m</div>[m
[32m+[m[32m<script>[m
[32m+[m[32m    // Retrieve the message from the URL query parameter[m
[32m+[m[32m    const urlParams = new URLSearchParams(window.location.search);[m
[32m+[m[32m    const message = urlParams.get('message');[m
[32m+[m
[32m+[m[32m    // Display a pop-up message if a message is received[m
[32m+[m[32m    if (message) {[m
[32m+[m[32m        alert(message);[m
[32m+[m[32m    }[m
[32m+[m[32m</script>[m
[32m+[m
[32m+[m[32m{% endblock %}[m
[1mdiff --git a/templates/voting_results.html b/templates/voting_results.html[m
[1mindex b8c32b1..c334e50 100644[m
[1m--- a/templates/voting_results.html[m
[1m+++ b/templates/voting_results.html[m
[36m@@ -1,78 +1,67 @@[m
 {% extends 'index.html' %}[m
 [m
 {% block content %}[m
[31m-    <div class="analyticsPage">[m
[31m-        <h1>Voting Analytics Dashboard</h1>[m
[32m+[m[32m<div