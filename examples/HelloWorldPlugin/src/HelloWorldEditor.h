#ifndef HELLOWORLDEDITOR_H
#define HELLOWORLDEDITOR_H

#include <juce_gui_basics/juce_gui_basics.h>

// JUCE GUI component that displays "Hello World"
class HelloWorldEditor : public juce::Component
{
public:
    HelloWorldEditor();
    ~HelloWorldEditor() override;

    void paint(juce::Graphics& g) override;
    void resized() override;

private:
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(HelloWorldEditor)
};

#endif // HELLOWORLDEDITOR_H
