#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

// Stable per-interactive-user identity. The mutex is acquired before any
// console, COM, Flutter, Dart or database initialization can occur.
constexpr wchar_t kOpcSingletonMutexName[] =
    L"Local\\OPC_ORGANIZATOR_POGREBNE_CEREMONIJE_SINGLE_INSTANCE";

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Fail closed if ownership cannot be established. A second launch exits
  // before it can create a Flutter engine or reach Dart/database bootstrap.
  ::SetLastError(ERROR_SUCCESS);
  HANDLE singleton_mutex = ::CreateMutexW(
      nullptr, TRUE, kOpcSingletonMutexName);
  if (singleton_mutex == nullptr) {
    return EXIT_FAILURE;
  }
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    ::CloseHandle(singleton_mutex);
    return EXIT_SUCCESS;
  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"OPC ORGANIZATOR POGREBNE CEREMONIJE", origin, size)) {
    ::ReleaseMutex(singleton_mutex);
    ::CloseHandle(singleton_mutex);
    return EXIT_FAILURE;
  }
  // Pokreni prozor maksimizirano (fullscreen) odmah pri startu
  ::ShowWindow(window.GetHandle(), SW_SHOWMAXIMIZED);
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  ::ReleaseMutex(singleton_mutex);
  ::CloseHandle(singleton_mutex);
  return EXIT_SUCCESS;
}
