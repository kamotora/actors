package ru.actors.ui;

import com.ericsson.otp.erlang.*;
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
    private JLabel ResponseLabel;
    private JPanel panel;
    private OtpNode send;
    private OtpNode receive;
    private OtpMbox jProcess;
    private OtpErlangPid jPid;
    private ScheduledExecutorService executor;

    @SneakyThrows
    public MainForm(OtpNode javaNode, OtpNode receiveNode) {
        executor = Executors.newSingleThreadScheduledExecutor();
        send = javaNode;
        receive = receiveNode;
        setContentPane(panel);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(new Dimension(600, 600));
        setVisible(true);
        jProcess = javaNode.createMbox();
        jPid = jProcess.self();
        OtpSelf self = new OtpSelf("me");
        OtpPeer customer = new OtpPeer(Node.CUSTOMER.getId());
        OtpConnection connection = self.connect(customer);
        connection.send(customer.node(), new OtpErlangString("KEK"));
        executor.scheduleAtFixedRate(new ReceiveRunnable(jProcess, ResponseLabel), 0, 1000, TimeUnit.MILLISECONDS);
        sendButton.addActionListener(actionEvent -> {
            sendMsg(Node.CUSTOMER, textArea1.getText());
        });
    }

    @SneakyThrows
    private void sendMsg(Node node, String text) {
        OtpErlangObject get_msg = new OtpErlangString(text);
//        connection.send(to.node(), get_msg);
//        connection.send(to.cookie(), get_msg);
//        connection.send(to.alive(), get_msg);
//        connection.send(to.host(), get_msg);

        jProcess.send("customer", node.getId(), get_msg);
        jProcess.send(node.getId(), get_msg);
        jProcess.receive(1000);
        log.info("Message sended to {}: {}", node.getId(), get_msg);
    }
}
