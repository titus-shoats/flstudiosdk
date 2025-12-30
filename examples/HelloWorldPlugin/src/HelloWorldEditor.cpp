#include "HelloWorldEditor.h"

HelloWorldEditor::HelloWorldEditor()
{
    // Set the size of our editor window
    setSize(400, 300);
}

HelloWorldEditor::~HelloWorldEditor()
{
}

void HelloWorldEditor::paint(juce::Graphics& g)
{
    // Fill the background with a nice gradient
    g.fillAll(juce::Colours::darkgrey);
    
    // Create a gradient from top to bottom
    juce::ColourGradient gradient(
        juce::Colours::lightblue, 0.0f, 0.0f,
        juce::Colours::darkblue, 0.0f, (float)getHeight(),
        false
    );
    g.setGradientFill(gradient);
    g.fillAll();
    
    // Draw "Hello World" text in the center
    g.setColour(juce::Colours::white);
    g.setFont(juce::Font(48.0f, juce::Font::bold));
    
    g.drawText("Hello World",
               getLocalBounds(),
               juce::Justification::centred,
               true);
    
    // Draw a subtitle
    g.setFont(juce::Font(16.0f));
    g.setColour(juce::Colours::lightgrey);
    
    auto textBounds = getLocalBounds();
    textBounds.removeFromTop(getHeight() / 2 + 30);
    
    g.drawText("FL Studio Native Plugin with JUCE GUI",
               textBounds.removeFromTop(30),
               juce::Justification::centred,
               true);
}

void HelloWorldEditor::resized()
{
    // This is where you would lay out child components if we had any
}
