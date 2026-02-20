name: Feature request
description: Suggest an improvement
title: "[Feature]: "
labels:
  - enhancement
body:
  - type: markdown
    attributes:
      value: |
        Thanks for sharing an idea. Clear use-cases help us prioritize better.
  - type: checkboxes
    id: checklist
    attributes:
      label: Before submitting
      options:
        - label: I searched existing issues and didn't find a duplicate.
          required: true
  - type: textarea
    id: problem
    attributes:
      label: Problem statement
      description: What user problem does this solve?
      placeholder: "It is hard to..."
    validations:
      required: true
  - type: textarea
    id: proposal
    attributes:
      label: Proposed solution
      description: Describe your preferred solution.
      placeholder: "Add a system which..."
    validations:
      required: true
  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives considered
      placeholder: "Certain alternatives, such as..."
  - type: dropdown
    id: area
    attributes:
      label: Area
      options:
        - QoL Update
        - Behaviour Request
        - UI Update
        - Docs Update
        - Other
    validations:
      required: true
