function App() {
  const callBackend = async () => {
    try {
      const res = await fetch("http://ab54b2798f6ed4db4b1c000159a36c66-266564533.us-east-1.elb.amazonaws.com/db");
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