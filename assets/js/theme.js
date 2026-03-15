const toggle = document.getElementById("themeToggle")

function setTheme(mode){

if(mode === "dark"){
document.body.classList.add("dark")
localStorage.setItem("theme","dark")
}

else{
document.body.classList.remove("dark")
localStorage.setItem("theme","light")
}

}

toggle.addEventListener("click",()=>{

if(document.body.classList.contains("dark")){
setTheme("light")
}
else{
setTheme("dark")
}

})

const saved = localStorage.getItem("theme")

if(saved === "dark"){
document.body.classList.add("dark")
}