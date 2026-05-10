let clerkInstance

function afterAuthRedirectUrl() {
  const meta = document.querySelector('meta[name="clerk-after-auth-redirect-url"]')
  const url = meta?.content?.trim()

  if (url) return url

  return `${window.location.origin}/`
}

export async function ensureClerk() {
  const meta = document.querySelector('meta[name="clerk-publishable-key"]')
  const publishableKey = meta?.content?.trim()

  if (!publishableKey) {
    const message =
      "Clerk publishable key is missing. Add it to Rails credentials (:clerk, :publishable_key) so the clerk-publishable-key meta tag renders."
    console.error(message)
    throw new Error(message)
  }

  if (!clerkInstance) {
    try {
      const mod = await import("@clerk/clerk-js")
      const Clerk = mod.Clerk || mod.default

      if (!Clerk) {
        throw new Error("Could not load Clerk from @clerk/clerk-js (no Clerk export).")
      }

      clerkInstance = new Clerk(publishableKey)
      await clerkInstance.load({})
    } catch (err) {
      console.error("Failed to initialize Clerk:", err)
      throw err instanceof Error ? err : new Error(String(err))
    }
  }

  return clerkInstance
}

export async function openClerkSignIn() {
  const clerk = await ensureClerk()

  const homeUrl = afterAuthRedirectUrl()

  await clerk.openSignIn({
    forceRedirectUrl: homeUrl,
    fallbackRedirectUrl: homeUrl,
    signUpForceRedirectUrl: homeUrl,
    signUpFallbackRedirectUrl: homeUrl,
  })
}

export async function openClerkSignUp() {
  const clerk = await ensureClerk()

  const homeUrl = afterAuthRedirectUrl()

  await clerk.openSignUp({
    forceRedirectUrl: homeUrl,
    fallbackRedirectUrl: homeUrl,
  })
}

export async function clerkSignOut() {
  const clerk = await ensureClerk()

  await clerk.signOut({ redirectUrl: afterAuthRedirectUrl() })
}
