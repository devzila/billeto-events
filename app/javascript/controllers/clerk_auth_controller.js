import { Controller } from "@hotwired/stimulus"

import { clerkSignOut, openClerkSignIn, openClerkSignUp } from "clerk_client"

export default class extends Controller {
  static targets = ["backdrop"]

  openGate(event) {
    event.preventDefault()
    event.stopPropagation()

    if (!this.hasBackdropTarget) return

    this.backdropTarget.classList.remove("d-none")
    this.backdropTarget.classList.add("d-flex")
    document.documentElement.style.overflow = "hidden"
  }

  closeGate() {
    if (!this.hasBackdropTarget) return

    this.backdropTarget.classList.add("d-none")
    this.backdropTarget.classList.remove("d-flex")
    document.documentElement.style.overflow = ""
  }

  backdropClose(event) {
    if (event.target !== this.backdropTarget) return

    this.closeGate()
  }

  async signIn(event) {
    event.preventDefault()
    event.stopPropagation()

    this.closeGate()
    try {
      await openClerkSignIn()
    } catch (err) {
      window.alert(err?.message || String(err))
    }
  }

  async signUp(event) {
    event.preventDefault()
    event.stopPropagation()

    this.closeGate()
    try {
      await openClerkSignUp()
    } catch (err) {
      window.alert(err?.message || String(err))
    }
  }

  async headerSignIn(event) {
    event.preventDefault()
    try {
      await openClerkSignIn()
    } catch (err) {
      window.alert(err?.message || String(err))
    }
  }

  async headerSignUp(event) {
    event.preventDefault()
    try {
      await openClerkSignUp()
    } catch (err) {
      window.alert(err?.message || String(err))
    }
  }

  async signOut(event) {
    event.preventDefault()
    try {
      await clerkSignOut()
    } catch (err) {
      window.alert(err?.message || String(err))
    }
  }
}
