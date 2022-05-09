import './style.css'
import { Elm } from "./Main.elm";

// const app = document.querySelector<HTMLDivElement>('#app')!
// 
// app.innerHTML = `
//   <h1>Hello Vite!</h1>
//   <a href="https://vitejs.dev/guide/features.html" target="_blank">Documentation</a>
// `
Elm.Main.init({
    node: document.getElementById("app"),
    flags: "Initial Message",
});
