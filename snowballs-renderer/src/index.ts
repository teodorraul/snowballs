import 'index.css'
import 'highlights.css'

type URLEncodedJSON = string
type ActionPayload = {
	type: "newMessage"
	id: string
	sender: "user" | "ai"
	html: string
} | {
	type: "updateMessage"
	id: string
	html: string
} | {
	type: "showChat"
	html: string
} 
var scrollStuckToBottom: Boolean = true

function scrollToBottom(evenIfScrolledBefore: Boolean) {
	if (evenIfScrolledBefore) {
		scrollStuckToBottom = true
	}
	if (scrollStuckToBottom == true) {
		window.scrollTo(0, document.body.scrollHeight)
	}
}

window.addEventListener('wheel', function(event) {
	if (scrollStuckToBottom == true) {
		scrollStuckToBottom = false
	}
})
window.addEventListener('touchmove', function(event) {
    if (scrollStuckToBottom == true) {
		scrollStuckToBottom = false
	}
});

window.invokeAction = (encodedPayload: URLEncodedJSON) => {
	const jsonPayload: ActionPayload = decodeURIComponent(encodedPayload)
	const payload = JSON.parse(jsonPayload).payload

	switch (payload.type) {
		case 'showChat': {
			document.body.innerHTML = payload.html
			
			scrollToBottom(true)
			break
		}
		case 'newMessage': {
			console.log("received payload", jsonPayload)
			let elem = document.createElement("div")
			elem.classList.add("message")
			elem.classList.add(payload.sender)
			elem.innerHTML = payload.html
			elem.id = payload.id
			document.body.appendChild(elem)
			
			scrollToBottom(true)
			break
		}
		case 'updateMessage': {
			let message = document.getElementById(payload.id)

			if (message) {
				message.innerHTML = payload.html
			}

			scrollToBottom(false)
			break
		}
	}
}

window.webkit.messageHandlers.core.postMessage("appIsReady");