function App() {
  const callBackend = async () => {
    try {
      const res = await fetch("/api/db");   // ✅ FIXED
      const data = await res.json();
      alert(JSON.stringify(data));
    } catch (err) {
      alert("Error connecting to backend");
    }
  };

  return (
    <div style={{ textAlign: "center", marginTop: "50px" }}>
      <h1>Cloud Platform Frontend 🚀</h1>
      <button onClick={callBackend}>Call Backend</button>
    </div>
  );
}

export default App;