# MySMS Messenger

It's a app to send SMS messages and look back at the ones you already sent. The texts actually go out through Twilio.

## What it does
- sign up and log in with a username and password
- send an SMS to a number
- every message you send is saved and shows up in your history
- you only see your own messages, not anyone else's
- each message shows its delivery status, which Twilio reports back through a webhook

## Stack
- Frontend: Angular
- Backend: Ruby on Rails
- Database: MongoDB 
- SMS: Twilio
- Tests: RSpec for the backend, Vitest for the frontend

## Running it locally
You'll need Ruby, Node, a MongoDB connection string and a Twilio account.

Backend:
```
cd backend
cp .env.example .env      # put your mongo + twilio values here
bundle install
bin/rails server          # http://localhost:3000
```

Frontend:
```
cd frontend
npm install
npm start                 # http://localhost:4200
```

Then open http://localhost:4200. The Angular dev server proxies everything under /api to Rails, so the login cookie just works and I didn't have to fight CORS in development.

## Tests
```
cd backend && bundle exec rspec
cd frontend && npx ng test --watch=false
```

## Bonuses
I did all three of them.

1. Auth - used Devise instead of writing my own. You log in with a username and password, and messages are stored per user now instead of by session.
2. Deploy - backend on Render, frontend on Vercel, database on MongoDB Atlas.
3. Webhook - Twilio sends the delivery status back and the message card updates to show it.

## Deploying
- Backend goes to Render and reads `render.yaml`. You add the env vars (mongo uri, twilio keys, the frontend url) in the Render dashboard.
- Frontend goes to Vercel with the root directory set to `frontend`. Change the render url inside `vercel.json` so /api points to your backend.

One honest note: the Twilio number is a trial toll-free number, so Twilio holds back real delivery until their toll-free verification is done. The full send → save → list → status flow works and every message gets a real Twilio id, it's only the final carrier delivery that's gated until that verification goes through.

Live demo: https://city-hive-mysms.vercel.app
