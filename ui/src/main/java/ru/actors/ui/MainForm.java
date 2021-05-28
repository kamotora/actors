package ru.actors.ui;

import com.ericsson.otp.erlang.OtpErlangPid;
import com.ericsson.otp.erlang.OtpMbox;
import com.ericsson.otp.erlang.OtpNode;
import lombok.SneakyThrows;
import lombok.extern.log4j.Log4j2;

import javax.swing.*;
import java.awt.*;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Log4j2
public class MainForm extends JFrame {
    private JTextArea textArea1;
    private JButton sendButton;
    private JPanel panel;
    private OtpNode send;
    private OtpNode receive;
    private OtpMbox receiveMbox;
    private OtpErlangPid jPid;
    private ScheduledExecutorService executor;

    @SneakyThrows
    public MainForm(OtpNode receiveNode) {
        executor = Executors.newSingleThreadScheduledExecutor();
        receive = receiveNode;
        setContentPane(panel);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(new Dimension(900, 600));
        setVisible(true);
        setTitle("Workers logs");
        receiveMbox = receiveNode.createMbox();
        boolean b = receiveMbox.registerName("loggerNode");
        if(!b)
            log.error("Error to register ");
        executor.scheduleAtFixedRate(new ReceiveRunnable(receiveMbox, textArea1), 0, 1000, TimeUnit.MILLISECONDS);
    }
}
