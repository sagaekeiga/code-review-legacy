module.exports = {
  "extends": ["standard", "standard-react"],
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    }
  },
  "rules": {
    "arrow-parens": [2, "as-needed"],
    "no-var": [2],
    "object-shorthand": [2, "properties"],
    "padding-line-between-statements": [2, {
      "blankLine": "never", "prev": "*", "next": "*"
    }],
    "prefer-const": [2, {
      "destructuring": "all",
      "ignoreReadBeforeAssign": false
    }],
    "quote-props": [2, "as-needed"],
    "react/prop-types": [0],
    "react/jsx-wrap-multilines": [2, {
      "declaration": "parens-new-line",
      "assignment": "parens-new-line",
      "return": "parens-new-line",
      "arrow": "parens-new-line",
      "condition": "parens-new-line",
      "logical": "parens-new-line",
      "prop": "parens-new-line"
    }]
  },
  "globals": {
    "Image": "readonly",
    "FileReader": "readonly",
    "StripeCheckout": "readonly"
  },
  "env": {
    "jquery": true
  }
}
