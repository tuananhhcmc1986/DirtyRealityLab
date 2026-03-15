async function loadReality(){

    const res = await fetch("./reality/index.json")
    const data = await res.json()
    
    if(!data.length) return
    
    const latest = data[data.length - 1]
    
    // format id -> 01, 02
    const latestId = String(latest.id).padStart(2,'0')
    
    const latestBox = document.getElementById("latestReality")
    
    latestBox.innerHTML = `
    <strong>Reality #${latest.id}</strong><br>
    ${latest.title}<br>
    <a href="./reality/${latestId}/">Read →</a>
    `
    
    const indexBox = document.getElementById("realityIndex")
    
    let html = ""
    
    data.forEach(r => {
    
    const rid = String(r.id).padStart(2,'0')
    
    html += `
    <p>
    #${r.id}
    <a href="./reality/${rid}/">
    ${r.title}
    </a>
    </p>
    `
    
    })
    
    indexBox.innerHTML = html
    
    }
    
    loadReality()