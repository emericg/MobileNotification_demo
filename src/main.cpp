#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Application name
    app.setApplicationName("MobileNotification demo");
    app.setApplicationDisplayName("MobileNotification demo");
    app.setOrganizationName("emeric");
    app.setOrganizationDomain("emeric");

    // Start the UI
    QQmlApplicationEngine engine;
    engine.loadFromModule("MobileNotification_demo", "MobileApplication");

    if (engine.rootObjects().isEmpty())
    {
        qWarning() << "Cannot init QmlApplicationEngine!";
        return EXIT_FAILURE;
    }

    return app.exec();
}
