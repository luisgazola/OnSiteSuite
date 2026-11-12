// Windows-only RAW printing to an explicitly selected spooler queue.
// Never invoke without technician's explicit confirmation of ESC/POS compatibility.
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

namespace OnSiteSuite.Printer {
  public static class RawSpooler {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct DocInfo {
      [MarshalAs(UnmanagedType.LPWStr)] public string DocumentName;
      [MarshalAs(UnmanagedType.LPWStr)] public string OutputFile;
      [MarshalAs(UnmanagedType.LPWStr)] public string DataType;
    }
    [DllImport("winspool.drv", EntryPoint="OpenPrinterW", CharSet=CharSet.Unicode, SetLastError=true)]
    private static extern bool OpenPrinter(string name, out IntPtr handle, IntPtr defaults);
    [DllImport("winspool.drv", EntryPoint="ClosePrinter", SetLastError=true)]
    private static extern bool ClosePrinter(IntPtr handle);
    [DllImport("winspool.drv", EntryPoint="StartDocPrinterW", CharSet=CharSet.Unicode, SetLastError=true)]
    private static extern int StartDocPrinter(IntPtr handle, int level, ref DocInfo doc);
    [DllImport("winspool.drv", EntryPoint="EndDocPrinter", SetLastError=true)]
    private static extern bool EndDocPrinter(IntPtr handle);
    [DllImport("winspool.drv", EntryPoint="StartPagePrinter", SetLastError=true)]
    private static extern bool StartPagePrinter(IntPtr handle);
    [DllImport("winspool.drv", EntryPoint="EndPagePrinter", SetLastError=true)]
    private static extern bool EndPagePrinter(IntPtr handle);
    [DllImport("winspool.drv", EntryPoint="WritePrinter", SetLastError=true)]
    private static extern bool WritePrinter(IntPtr handle, byte[] buffer, int count, out int written);

    public static int Send(string queue, byte[] data) {
      if (String.IsNullOrWhiteSpace(queue) || data == null || data.Length == 0)
        throw new ArgumentException("Fila ou conteúdo inválido");
      IntPtr printer;
      if (!OpenPrinter(queue, out printer, IntPtr.Zero))
        throw new Win32Exception(Marshal.GetLastWin32Error(), "Falha ao abrir fila de impressão");
      bool documentStarted = false, pageStarted = false;
      try {
        var doc = new DocInfo { DocumentName = "OnSiteSuite ESC/POS", OutputFile = null, DataType = "RAW" };
        int jobId = StartDocPrinter(printer, 1, ref doc);
        if (jobId <= 0) throw new Win32Exception(Marshal.GetLastWin32Error(), "Falha ao iniciar job RAW");
        documentStarted = true;
        if (!StartPagePrinter(printer)) throw new Win32Exception(Marshal.GetLastWin32Error(), "Falha ao iniciar página RAW");
        pageStarted = true;
        int written;
        if (!WritePrinter(printer, data, data.Length, out written) || written != data.Length)
          throw new Win32Exception(Marshal.GetLastWin32Error(), "Escrita RAW incompleta");
        return jobId;
      } finally {
        if (pageStarted) EndPagePrinter(printer);
        if (documentStarted) EndDocPrinter(printer);
        ClosePrinter(printer);
      }
    }
  }
}
