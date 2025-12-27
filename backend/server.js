const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const admin = require("firebase-admin");

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// --- FIREBASE CONNECTION ---
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// --- ROUTES ---

// 0. GET: Home Page (Check if server is running)
app.get("/", (req, res) => {
  res.send("✅ Todo List API is running! Go to /tasks to see data.");
});

// 1. GET: Fetch all tasks
app.get("/tasks", async (req, res) => {
  try {
    const snapshot = await db.collection("tasks").get();
    const tasks = [];
    snapshot.forEach((doc) => {
      tasks.push(doc.data());
    });
    res.json(tasks);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 2. POST: Add a new task
app.post("/tasks", async (req, res) => {
  const newTask = req.body;
  if (!newTask.id) newTask.id = Date.now().toString();

  try {
    await db.collection("tasks").doc(newTask.id).set(newTask);
    console.log("Task added:", newTask);
    res.status(201).json(newTask);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 3. PUT: Update a task
app.put("/tasks/:id", async (req, res) => {
  const { id } = req.params;
  const updatedData = req.body;

  try {
    await db.collection("tasks").doc(id).update(updatedData);
    const doc = await db.collection("tasks").doc(id).get();
    res.json(doc.data());
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 4. DELETE: Remove a task
app.delete("/tasks/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await db.collection("tasks").doc(id).delete();
    res.json({ message: "Deleted successfully" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
