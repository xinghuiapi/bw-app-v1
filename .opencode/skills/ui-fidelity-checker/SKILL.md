---
name: "ui-fidelity-checker"
description: "Checks UI fidelity against the original design to ensure >80% accuracy. Invoke when user asks to align with the original project, check UI fidelity, or after completing a high-fidelity UI task."
---

# UI Fidelity Checker

This skill acts as a rigorous quality assurance step to ensure that the developed UI matches the original design or target image with high fidelity (at least 80% accuracy).

## Trigger Scenarios
- When the user explicitly requests "对齐原项目" (align with the original project).
- When the user asks for "高还原度" (high fidelity restoration).
- Automatically after you finish implementing a UI screen that requires matching a specific design or image.

## Fidelity Check Checklist

Whenever this skill is invoked, you MUST evaluate the implemented UI against the original design across the following dimensions:

1. **Layout & Spacing (布局与间距)**
   - Are the margins and paddings (left/right, top/bottom) consistent with the design?
   - Are the spaces between elements (e.g., `SizedBox(height: ...)` or `SizedBox(width: ...)`) proportional to the design?
   - Is the overall layout structure (e.g., Row, Column, Grid, Stack) correctly representing the visual hierarchy?

2. **Colors & Gradients (颜色与渐变)**
   - Are the background colors matching exactly (e.g., using a color picker or close hex approximation)?
   - Are gradients applied in the correct direction (e.g., `begin`, `end`) with the correct color stops?
   - Do the text colors and icon colors match the design?

3. **Typography (字体与排版)**
   - Are the font sizes visually proportional to the design?
   - Are font weights (e.g., `FontWeight.bold`, `FontWeight.w500`) applied correctly to headings vs. body text?
   - Is the text alignment correct (left, center, right)?

4. **Shapes & Decorations (形状与装饰)**
   - Are the border radii (`BorderRadius.circular`) matching the design (e.g., pill-shaped buttons, rounded cards)?
   - Are shadows (`BoxShadow`) applied correctly if present in the design (color, blurRadius, offset)?
   - Are borders (`Border.all`) present where necessary?

5. **Icons & Imagery (图标与图片)**
   - Are the selected icons semantically and visually similar to the original design?
   - Are the icon sizes proportional to the surrounding text?

6. **Micro-interactions & Details (微交互与细节)**
   - Are dividers/separators present with the correct color and opacity?
   - Are tags/badges aligned and styled correctly?

## Action Plan

If the fidelity check reveals that the UI falls below the ~80% threshold:
1. **Identify the Discrepancies**: List out the specific areas where the UI diverges from the design.
2. **Propose Fixes**: State exactly what needs to be changed (e.g., "Change the background color of the wallet card to a linear gradient, update the icon size to 32.sp").
3. **Implement Corrections**: Immediately rewrite or update the relevant code to fix the discrepancies without waiting for further prompts.
