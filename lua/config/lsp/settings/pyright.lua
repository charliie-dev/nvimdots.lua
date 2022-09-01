return {
	settings = {
		python = {
      exclude = {
        "**/node_modules",
        "**/__pycache__",
        "src/experimental",
        "src/typestubs",
      },
			analysis = {
        typeCheckingMode = "basic",
        diagnosticMode = "workspace",
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
        },
			},
		},
	},
}
