# start_backend.ps1

# Navigate to project root
Set-Location "C:\Users\harun\Personalised Learning App"

# Temporarily allow script execution (for this session only)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Run Flask app
python backend/app.py

# Open in default browser (optional)
Start-Process "http://127.0.0.1:5000"
