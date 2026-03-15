async function loadReality(){

    const res = await fetch("./reality/index.json")
    const data = await res.json()
    
    const latest = data[data.length - 1]
    
    const latestBox = document.getElementById("latestReality")
    
    latestBox.innerHTML = `
    <strong>Reality #${latest.id}</strong><br>
    ${latest.title}<br>
    <a href="/reality/${latest.id}/">Read →</a>
    `
    
    const indexBox = document.getElementById("realityIndex")
    
    let html = ""
    
    data.forEach(r => {
    
    html += `
    <p>
    #${r.id}
    <a href="/reality/${r.id}/">
    ${r.title}
    </a>
    </p>
    `
    
    })
    
    indexBox.innerHTML = html
    
    }
    
    loadReality()